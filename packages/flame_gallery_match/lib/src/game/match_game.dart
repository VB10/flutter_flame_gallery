import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_match/src/component/board_component.dart';
import 'package:flame_gallery_match/src/component/piece_component.dart';
import 'package:flame_gallery_match/src/component/piece_grid.dart';
import 'package:flame_gallery_match/src/config/match_config.dart';
import 'package:flame_gallery_match/src/game/match_stat_keys.dart';
import 'package:flame_gallery_match/src/logic/cascade_step.dart';
import 'package:flame_gallery_match/src/logic/cell.dart';
import 'package:flame_gallery_match/src/logic/match_board.dart';
import 'package:flame_gallery_match/src/logic/stage_queue.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum MatchEndCause { outOfMoves, timeUp, target, quit }

/// Board rules run instantly in [MatchBoard]; this class replays the result
/// as a queue of timed animation stages and keeps input locked meanwhile.
final class MatchGame extends GalleryFlameGame
    with GameEndCause<MatchEndCause> {
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
       _countdown = RoundCountdown(config.timeLimit);

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
  final RoundCountdown _countdown;
  final StageQueue _stages = StageQueue();
  late final PieceGrid _pieces = PieceGrid(
    rows: config.rows,
    columns: config.columns,
  );
  late final List<Sprite> _sprites;
  late final BoardComponent _boardView;
  late MatchBoard _board;
  bool _busy = false;
  int _movesUsed = 0;
  int _maxCascade = 0;

  /// Time ran out during a cascade; the round ends once it settles.
  bool _timeUpPending = false;

  ValueListenable<int?> get movesLeft => _movesLeft;
  ValueListenable<int?> get secondsLeft => _countdown.secondsLeft;

  /// `true` while a swap and its cascades are animating.
  bool get isBusy => _busy;
  bool get canInteract => isPlaying && !_busy;

  @visibleForTesting
  MatchBoard get board => _board;

  @override
  Color backgroundColor() => resolveBackground(colors.surface);

  @override
  Future<void> onLoad() async {
    _sprites = await loadSprites(config.pieces.map((piece) => piece.sprite));
    await addBackground(config.background);
    _boardView = BoardComponent(
      rows: config.rows,
      columns: config.columns,
      colors: colors,
    );
    await add(_boardView);
    _board = _createBoard();
    _layoutBoard();
    _rebuildPieces();
    await super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    if (isLoaded) _layoutBoard();
  }

  @override
  void onRoundStart() {
    _stages.clear();
    _busy = false;
    _movesUsed = 0;
    _maxCascade = 0;
    _timeUpPending = false;
    _movesLeft.value = config.moveLimit;
    _countdown.reset();
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
    _stages.update(dt);
  }

  @override
  Map<String, Object> collectStats() => {
    MatchStatKeys.movesUsed: _movesUsed,
    MatchStatKeys.maxCascade: _maxCascade,
    ...super.collectStats(),
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
      _useMove();
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

  void _useMove() {
    _movesUsed++;
    final limit = config.moveLimit;
    if (limit != null) _movesLeft.value = limit - _movesUsed;
  }

  /// Fits the largest square cells below the HUD and centres the board.
  void _layoutBoard() {
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
    for (final (cell, piece) in _pieces.entries) {
      piece
        ..snapTo(_boardView.centerOf(cell))
        ..size = _pieceSize;
    }
  }

  Vector2 get _pieceSize => Vector2.all(_boardView.cellSize * _pieceFactor);

  PieceComponent _newPiece(int piece, Cell at) => PieceComponent(
    piece: piece,
    sprite: _sprites[piece],
    position: _boardView.centerOf(at),
    size: _pieceSize,
  );

  /// Replaces every piece component with a fresh one matching [_board].
  void _rebuildPieces({bool popIn = false}) {
    _boardView.removeAll(_boardView.children.whereType<PieceComponent>());
    for (final cell in _pieces.cells) {
      final piece = _newPiece(_board.pieceAt(cell), cell);
      if (popIn) piece.popIn(_shuffleDuration);
      _pieces[cell] = piece;
      _boardView.add(piece);
    }
  }

  double _animateSwap(Cell a, Cell b) {
    sounds.play(GameSoundCue.swap);
    _pieces[a]?.moveTo(_boardView.centerOf(b), _swapDuration);
    _pieces[b]?.moveTo(_boardView.centerOf(a), _swapDuration);
    _pieces.swap(a, b);
    return _swapDuration;
  }

  double _animateClear(CascadeStep step) {
    for (final cell in step.cleared) {
      final piece = _pieces.take(cell);
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
    }
    sounds.play(GameSoundCue.match);
    _maxCascade = math.max(_maxCascade, step.level);
    addScore(step.score(config.pointsPerPiece));
    return _clearDuration;
  }

  double _animateFall(CascadeStep step) {
    // Lift every falling piece before placing any: a piece may land on the
    // cell another one is just leaving.
    final moved = [
      for (final fall in step.falls)
        (piece: _pieces.take(fall.from), to: fall.to),
    ];
    for (final (:piece, :to) in moved) {
      _pieces[to] = piece;
      piece?.moveTo(_boardView.centerOf(to), _fallDuration);
    }
    for (final spawn in step.spawns) {
      final above = (row: spawn.startRow, column: spawn.cell.column);
      final piece = _newPiece(spawn.piece, above);
      _pieces[spawn.cell] = piece;
      _boardView.add(piece);
      piece.moveTo(_boardView.centerOf(spawn.cell), _fallDuration);
    }
    return _fallDuration;
  }

  double _animateShuffle() {
    _rebuildPieces(popIn: true);
    return _shuffleDuration;
  }

  /// Last stage of every swap: unlocks input, then applies any end condition
  /// that came up while the board was busy.
  double _settle() {
    _busy = false;
    if (!isPlaying) return 0;
    final cause = _endCondition();
    if (cause != null) finishWith(cause);
    return 0;
  }

  MatchEndCause? _endCondition() {
    final target = config.targetScore;
    final limit = config.moveLimit;
    if (_timeUpPending) return MatchEndCause.timeUp;
    if (target != null && score.value >= target) return MatchEndCause.target;
    if (limit != null && _movesUsed >= limit) return MatchEndCause.outOfMoves;
    return null;
  }

  void _tickTimer(double dt) {
    if (!isPlaying || !_countdown.tick(dt)) return;
    // Let a running cascade finish so every point the board awarded counts.
    if (_busy) {
      _timeUpPending = true;
    } else {
      finishWith(MatchEndCause.timeUp);
    }
  }

  @override
  void onRemove() {
    _movesLeft.dispose();
    _countdown.dispose();
    super.onRemove();
  }
}
