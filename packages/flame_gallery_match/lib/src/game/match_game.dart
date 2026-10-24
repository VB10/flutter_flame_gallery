import 'dart:collection';
import 'dart:math' as math;

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_match/src/component/board_component.dart';
import 'package:flame_gallery_match/src/component/piece_component.dart';
import 'package:flame_gallery_match/src/config/match_config.dart';
import 'package:flame_gallery_match/src/logic/cascade_step.dart';
import 'package:flame_gallery_match/src/logic/cell.dart';
import 'package:flame_gallery_match/src/logic/match_board.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum MatchEndCause { outOfMoves, timeUp, target, quit }

/// Applies one animation stage and returns how long to wait before the next.
typedef _Stage = double Function();

/// Board rules run instantly in [MatchBoard]; this class replays the result
/// as a queue of timed animation stages and keeps input locked meanwhile.
final class MatchGame extends GalleryFlameGame {
  MatchGame({
    required this.config,
    required this.colors,
    required super.gameId,
    math.Random? random,
    @visibleForTesting this._initialGrid,
  }) : assert(
         config.pieces.length >= MatchConfig.minPieces,
         'At least ${MatchConfig.minPieces} MatchPiece kinds are required',
       ),
       _random = random ?? math.Random(config.seed),
       _movesLeft = ValueNotifier<int?>(config.moveLimit),
       _secondsLeft = ValueNotifier<int?>(_ceilSeconds(config.timeLimit)) {
    images = Images(prefix: '');
  }

  /// Top share of the screen kept free for the HUD.
  static const _hudFraction = 0.15;

  /// Piece size relative to its cell.
  static const _pieceFactor = 0.86;
  static const _burstSpeed = 180.0;
  static const _swapDuration = 0.16;
  static const _clearDuration = 0.16;
  static const _fallDuration = 0.24;
  static const _shuffleDuration = 0.3;

  final MatchConfig config;
  final ColorScheme colors;

  math.Random _random;
  final math.Random _effectsRandom = math.Random();
  final List<List<int>>? _initialGrid;
  final ValueNotifier<int?> _movesLeft;
  final ValueNotifier<int?> _secondsLeft;
  final List<Sprite> _sprites = [];
  final ListQueue<_Stage> _stages = ListQueue<_Stage>();
  late final BoardComponent _boardView;
  late MatchBoard _board;
  List<List<PieceComponent?>> _pieces = const [];
  double _stageWait = 0;
  bool _busy = false;
  int _movesUsed = 0;
  int _maxCascade = 0;
  double _timeLeft = 0;
  bool _timeUpPending = false;
  MatchEndCause? _endCause;

  ValueListenable<int?> get movesLeft => _movesLeft;
  ValueListenable<int?> get secondsLeft => _secondsLeft;

  /// `true` while a swap and its cascades are animating.
  bool get isBusy => _busy;
  bool get canInteract => isPlaying && !_busy;

  @visibleForTesting
  MatchBoard get board => _board;

  @override
  Color backgroundColor() => colors.surface;

  @override
  Future<void> onLoad() async {
    for (final piece in config.pieces) {
      _sprites.add(Sprite(await images.load(piece.sprite.key)));
    }
    final background = config.background;
    if (background != null) {
      await add(_Background(sprite: Sprite(await images.load(background.key))));
    }
    _boardView = BoardComponent(
      rows: config.rows,
      columns: config.columns,
      colors: colors,
    );
    await add(_boardView);
    _board = _createBoard();
    _layout();
    _rebuildPieces();
    await super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) _layout();
  }

  @override
  void onRoundStart() {
    _stages.clear();
    _stageWait = 0;
    _busy = false;
    _movesUsed = 0;
    _maxCascade = 0;
    _endCause = null;
    _timeUpPending = false;
    _timeLeft = (config.timeLimit?.inMilliseconds ?? 0) / 1000;
    _movesLeft.value = config.moveLimit;
    _secondsLeft.value = _ceilSeconds(config.timeLimit);
    _boardView.selected = null;
    final seed = config.seed;
    if (seed != null) _random = math.Random(seed);
    _board = _createBoard();
    _rebuildPieces();
  }

  @override
  void update(double dt) {
    super.update(dt);
    _tickTimer(dt);
    _runStages(dt);
  }

  @override
  Map<String, Object> collectStats() => {
    'movesUsed': _movesUsed,
    'maxCascade': _maxCascade,
    'endedBy': (_endCause ?? MatchEndCause.quit).name,
  };

  /// Swaps two neighbouring pieces. A swap that makes no match bounces back
  /// and does not cost a move.
  @internal
  void requestSwap(Cell a, Cell b) {
    if (!canInteract || !_board.canSwap(a, b)) return;
    _busy = true;
    _boardView.selected = null;
    final steps = _board.trySwap(a, b);
    _stages.add(() => _animateSwap(a, b));
    if (steps.isEmpty) {
      _stages.add(() => _animateSwap(a, b));
    } else {
      _movesUsed++;
      final limit = config.moveLimit;
      if (limit != null) _movesLeft.value = limit - _movesUsed;
      for (final step in steps) {
        _stages
          ..add(() => _animateClear(step))
          ..add(() => _animateFall(step));
      }
      if (!_board.hasAnyMove()) {
        _board.shuffle();
        _stages.add(_animateShuffle);
      }
    }
    _stages.add(_settle);
  }

  MatchBoard _createBoard() {
    final grid = _initialGrid;
    return grid == null
        ? MatchBoard.generate(
            rows: config.rows,
            columns: config.columns,
            pieceCount: config.pieces.length,
            random: _random,
          )
        : MatchBoard.fromGrid(
            grid,
            pieceCount: config.pieces.length,
            random: _random,
          );
  }

  void _layout() {
    final top = size.y * _hudFraction;
    const padding = GallerySpacing.md;
    final cell = math.min(
      (size.x - padding * 2) / config.columns,
      (size.y - top - padding * 2) / config.rows,
    );
    final boardSize = Vector2(cell * config.columns, cell * config.rows);
    _boardView
      ..cellSize = cell
      ..size = boardSize
      ..position = Vector2(
        (size.x - boardSize.x) / 2,
        top + (size.y - top - boardSize.y) / 2,
      );
    for (var row = 0; row < _pieces.length; row++) {
      for (var column = 0; column < _pieces[row].length; column++) {
        _pieces[row][column]
          ?..snapTo(_boardView.centerOf((row: row, column: column)))
          ..size = _pieceSize;
      }
    }
  }

  Vector2 get _pieceSize => Vector2.all(_boardView.cellSize * _pieceFactor);

  PieceComponent _newPiece(int piece, Cell at) => PieceComponent(
    piece: piece,
    sprite: _sprites[piece],
    position: _boardView.centerOf(at),
    size: _pieceSize,
  );

  void _rebuildPieces({bool popIn = false}) {
    _boardView.removeAll(_boardView.children.whereType<PieceComponent>());
    _pieces = [
      for (var row = 0; row < config.rows; row++)
        [
          for (var column = 0; column < config.columns; column++)
            _newPiece(_board.pieceAt((row: row, column: column)), (
              row: row,
              column: column,
            )),
        ],
    ];
    for (final piece in _pieces.expand((row) => row).nonNulls) {
      if (popIn) piece.popIn(_shuffleDuration);
      _boardView.add(piece);
    }
  }

  void _runStages(double dt) {
    if (_stageWait > 0) _stageWait -= dt;
    while (_stageWait <= 0 && _stages.isNotEmpty) {
      _stageWait = _stages.removeFirst()();
    }
  }

  double _animateSwap(Cell a, Cell b) {
    final pieceA = _pieces[a.row][a.column];
    final pieceB = _pieces[b.row][b.column];
    pieceA?.moveTo(_boardView.centerOf(b), _swapDuration);
    pieceB?.moveTo(_boardView.centerOf(a), _swapDuration);
    _pieces[a.row][a.column] = pieceB;
    _pieces[b.row][b.column] = pieceA;
    return _swapDuration;
  }

  double _animateClear(CascadeStep step) {
    for (final cell in step.cleared) {
      final piece = _pieces[cell.row][cell.column];
      if (piece == null) continue;
      piece.vanish(_clearDuration);
      _boardView.add(
        GalleryBurst.at(
          position: piece.position,
          color: config.pieces[piece.piece].color,
          random: _effectsRandom,
          speed: _burstSpeed,
        ),
      );
      _pieces[cell.row][cell.column] = null;
    }
    _maxCascade = math.max(_maxCascade, step.level);
    addScore(step.score(config.pointsPerPiece));
    return _clearDuration;
  }

  double _animateFall(CascadeStep step) {
    final moved = [
      for (final fall in step.falls)
        (piece: _pieces[fall.from.row][fall.from.column], to: fall.to),
    ];
    for (final fall in step.falls) {
      _pieces[fall.from.row][fall.from.column] = null;
    }
    for (final (:piece, :to) in moved) {
      _pieces[to.row][to.column] = piece;
      piece?.moveTo(_boardView.centerOf(to), _fallDuration);
    }
    for (final spawn in step.spawns) {
      final piece = _newPiece(spawn.piece, (
        row: spawn.startRow,
        column: spawn.cell.column,
      ));
      _pieces[spawn.cell.row][spawn.cell.column] = piece;
      _boardView.add(piece);
      piece.moveTo(_boardView.centerOf(spawn.cell), _fallDuration);
    }
    return _fallDuration;
  }

  double _animateShuffle() {
    _rebuildPieces(popIn: true);
    return _shuffleDuration;
  }

  double _settle() {
    _busy = false;
    if (!isPlaying) return 0;
    if (_timeUpPending) {
      _end(MatchEndCause.timeUp);
      return 0;
    }
    final target = config.targetScore;
    final limit = config.moveLimit;
    if (target != null && score.value >= target) {
      _end(MatchEndCause.target);
    } else if (limit != null && _movesUsed >= limit) {
      _end(MatchEndCause.outOfMoves);
    }
    return 0;
  }

  void _tickTimer(double dt) {
    if (!isPlaying || config.timeLimit == null || _timeUpPending) return;
    _timeLeft -= dt;
    final seconds = math.max(0, _timeLeft.ceil());
    if (seconds != _secondsLeft.value) _secondsLeft.value = seconds;
    if (_timeLeft > 0) return;
    // Let a running cascade finish so every point the board awarded counts.
    if (_busy) {
      _timeUpPending = true;
    } else {
      _end(MatchEndCause.timeUp);
    }
  }

  void _end(MatchEndCause cause) {
    _endCause = cause;
    finish();
  }

  static int? _ceilSeconds(Duration? duration) => duration == null
      ? null
      : (duration.inMilliseconds / Duration.millisecondsPerSecond).ceil();

  @override
  void onRemove() {
    _movesLeft.dispose();
    _secondsLeft.dispose();
    super.onRemove();
  }
}

final class _Background extends SpriteComponent {
  _Background({required super.sprite}) : super(priority: -1);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }
}
