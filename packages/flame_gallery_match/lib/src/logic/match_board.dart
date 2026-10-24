import 'dart:math' as math;

import 'package:flame_gallery_match/src/logic/cascade_step.dart';
import 'package:flame_gallery_match/src/logic/cell.dart';

/// Pure match-three rules: a grid of piece indices, swaps, matches,
/// gravity and refill. No Flame, fully deterministic for a given [math.Random].
final class MatchBoard {
  MatchBoard._({
    required this.rows,
    required this.columns,
    required this.pieceCount,
    required this._grid,
    required this._random,
  });

  /// A random board with no ready-made matches and at least one valid move.
  factory MatchBoard.generate({
    required int rows,
    required int columns,
    required int pieceCount,
    required math.Random random,
  }) => MatchBoard._(
    rows: rows,
    columns: columns,
    pieceCount: pieceCount,
    grid: List.generate(rows, (_) => List.filled(columns, empty)),
    random: random,
  ).._fillWithoutMatches();

  /// A board with a fixed layout, e.g. for tests or authored levels.
  factory MatchBoard.fromGrid(
    List<List<int>> grid, {
    required int pieceCount,
    required math.Random random,
  }) => MatchBoard._(
    rows: grid.length,
    columns: grid.first.length,
    pieceCount: pieceCount,
    grid: [
      for (final row in grid) [...row],
    ],
    random: random,
  );

  static const empty = -1;
  static const minRun = 3;
  static const _maxShuffleAttempts = 100;

  final int rows;
  final int columns;
  final int pieceCount;
  final List<List<int>> _grid;
  final math.Random _random;

  int pieceAt(Cell cell) => _grid[cell.row][cell.column];

  List<List<int>> get snapshot => [
    for (final row in _grid) List<int>.unmodifiable(row),
  ];

  bool contains(Cell cell) =>
      cell.row >= 0 &&
      cell.row < rows &&
      cell.column >= 0 &&
      cell.column < columns;

  bool canSwap(Cell a, Cell b) =>
      contains(a) && contains(b) && a.isAdjacentTo(b);

  /// Swaps and resolves every cascade. An empty list means the swap made no
  /// match and was undone, leaving the board unchanged.
  List<CascadeStep> trySwap(Cell a, Cell b) {
    if (!canSwap(a, b)) return const [];
    _swap(a, b);
    if (findMatches().isEmpty) {
      _swap(a, b);
      return const [];
    }
    return resolve();
  }

  /// Clears matches until the board is stable, recording every step.
  List<CascadeStep> resolve() {
    final steps = <CascadeStep>[];
    for (var level = 1; ; level++) {
      final cleared = findMatches();
      if (cleared.isEmpty) return steps;
      for (final cell in cleared) {
        _grid[cell.row][cell.column] = empty;
      }
      steps.add(
        CascadeStep(
          level: level,
          cleared: cleared,
          falls: _applyGravity(),
          spawns: _refill(),
        ),
      );
    }
  }

  /// Every cell that is part of a horizontal or vertical run of [minRun]+.
  Set<Cell> findMatches() {
    final matches = <Cell>{};
    for (var row = 0; row < rows; row++) {
      _collectRuns(matches, columns, (i) => (row: row, column: i));
    }
    for (var column = 0; column < columns; column++) {
      _collectRuns(matches, rows, (i) => (row: i, column: column));
    }
    return matches;
  }

  bool hasAnyMove() {
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        final cell = (row: row, column: column);
        for (final neighbour in [
          (row: row, column: column + 1),
          (row: row + 1, column: column),
        ]) {
          if (!contains(neighbour)) continue;
          _swap(cell, neighbour);
          final matches = findMatches().isNotEmpty;
          _swap(cell, neighbour);
          if (matches) return true;
        }
      }
    }
    return false;
  }

  /// Rearranges the existing pieces into a stable board with a valid move.
  void shuffle() {
    final pieces = [for (final row in _grid) ...row];
    for (var attempt = 0; attempt < _maxShuffleAttempts; attempt++) {
      pieces.shuffle(_random);
      for (var i = 0; i < pieces.length; i++) {
        _grid[i ~/ columns][i % columns] = pieces[i];
      }
      if (findMatches().isEmpty && hasAnyMove()) return;
    }
    _fillWithoutMatches();
  }

  void _swap(Cell a, Cell b) {
    final piece = pieceAt(a);
    _grid[a.row][a.column] = pieceAt(b);
    _grid[b.row][b.column] = piece;
  }

  void _collectRuns(Set<Cell> into, int length, Cell Function(int) cellAt) {
    var start = 0;
    for (var i = 1; i <= length; i++) {
      if (i < length && pieceAt(cellAt(i)) == pieceAt(cellAt(start))) continue;
      if (i - start >= minRun && pieceAt(cellAt(start)) != empty) {
        for (var k = start; k < i; k++) {
          into.add(cellAt(k));
        }
      }
      start = i;
    }
  }

  List<PieceFall> _applyGravity() {
    final falls = <PieceFall>[];
    for (var column = 0; column < columns; column++) {
      var target = rows - 1;
      for (var row = rows - 1; row >= 0; row--) {
        final piece = _grid[row][column];
        if (piece == empty) continue;
        if (row != target) {
          _grid[target][column] = piece;
          _grid[row][column] = empty;
          falls.add(
            PieceFall(
              from: (row: row, column: column),
              to: (row: target, column: column),
            ),
          );
        }
        target--;
      }
    }
    return falls;
  }

  List<PieceSpawn> _refill() {
    final spawns = <PieceSpawn>[];
    for (var column = 0; column < columns; column++) {
      var holes = 0;
      while (holes < rows && _grid[holes][column] == empty) {
        holes++;
      }
      for (var row = 0; row < holes; row++) {
        final piece = _random.nextInt(pieceCount);
        _grid[row][column] = piece;
        spawns.add(
          PieceSpawn(
            cell: (row: row, column: column),
            piece: piece,
            startRow: row - holes,
          ),
        );
      }
    }
    return spawns;
  }

  void _fillWithoutMatches() {
    do {
      for (var row = 0; row < rows; row++) {
        for (var column = 0; column < columns; column++) {
          _grid[row][column] = _pickWithoutMatch(row, column);
        }
      }
    } while (!hasAnyMove());
  }

  /// A random piece that does not complete a run with the two cells to the
  /// left or the two cells above (the only ones filled so far).
  int _pickWithoutMatch(int row, int column) {
    final banned = <int>{
      if (column >= 2 && _grid[row][column - 1] == _grid[row][column - 2])
        _grid[row][column - 1],
      if (row >= 2 && _grid[row - 1][column] == _grid[row - 2][column])
        _grid[row - 1][column],
    };
    final options = [
      for (var piece = 0; piece < pieceCount; piece++)
        if (!banned.contains(piece)) piece,
    ];
    return options[_random.nextInt(options.length)];
  }
}
