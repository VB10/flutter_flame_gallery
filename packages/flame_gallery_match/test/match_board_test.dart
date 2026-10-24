import 'dart:math' as math;

import 'package:flame_gallery_match/src/logic/cell.dart';
import 'package:flame_gallery_match/src/logic/match_board.dart';
import 'package:flutter_test/flutter_test.dart';

/// 5×5, four kinds, no matches. Swapping (0,1)↔(1,1) lines up three 0s in
/// row 0; swapping (4,3)↔(4,4) matches nothing.
const _stable = [
  [0, 1, 0, 2, 3],
  [1, 0, 2, 3, 1],
  [2, 3, 1, 0, 2],
  [3, 2, 3, 1, 0],
  [0, 1, 2, 3, 1],
];

const int _x = MatchBoard.empty;

MatchBoard _board(List<List<int>> grid, {int seed = 1}) =>
    MatchBoard.fromGrid(grid, pieceCount: 4, random: math.Random(seed));

Set<Cell> _cells(List<(int, int)> cells) => {
  for (final (row, column) in cells) (row: row, column: column),
};

void main() {
  group('generate', () {
    test('never starts with a match and always has a move', () {
      for (var seed = 0; seed < 200; seed++) {
        for (final (rows, columns, kinds) in [
          (8, 8, 6),
          (5, 5, 4),
          (10, 7, 5),
        ]) {
          final board = MatchBoard.generate(
            rows: rows,
            columns: columns,
            pieceCount: kinds,
            random: math.Random(seed),
          );
          expect(board.findMatches(), isEmpty, reason: 'seed $seed');
          expect(board.hasAnyMove(), isTrue, reason: 'seed $seed');
        }
      }
    });

    test('is deterministic for a seed', () {
      MatchBoard make() => MatchBoard.generate(
        rows: 8,
        columns: 8,
        pieceCount: 6,
        random: math.Random(42),
      );
      expect(make().snapshot, make().snapshot);
    });
  });

  group('findMatches', () {
    test('stable board has none', () {
      expect(_board(_stable).findMatches(), isEmpty);
    });

    test('horizontal and vertical runs of three', () {
      final board = _board(const [
        [0, 0, 0, 1, 2],
        [1, 2, 3, 1, 3],
        [2, 3, 0, 1, 0],
        [3, 2, 3, 2, 1],
        [0, 1, 2, 3, 0],
      ]);
      expect(
        board.findMatches(),
        _cells([(0, 0), (0, 1), (0, 2), (0, 3), (1, 3), (2, 3)]),
      );
    });

    test('L and T shapes merge into one set', () {
      final lShape = _board(const [
        [0, 1, 2, 3, 1],
        [0, 2, 3, 1, 2],
        [0, 0, 0, 2, 3],
        [1, 3, 1, 3, 1],
        [2, 1, 2, 1, 2],
      ]);
      expect(
        lShape.findMatches(),
        _cells([(0, 0), (1, 0), (2, 0), (2, 1), (2, 2)]),
      );

      final tShape = _board(const [
        [1, 1, 1, 0, 2],
        [3, 1, 2, 3, 0],
        [2, 1, 3, 2, 3],
        [0, 2, 0, 3, 1],
        [3, 0, 2, 1, 0],
      ]);
      expect(
        tShape.findMatches(),
        _cells([(0, 0), (0, 1), (0, 2), (1, 1), (2, 1)]),
      );
    });

    test('five in a row is one run of five', () {
      final board = _board(const [
        [2, 2, 2, 2, 2],
        [0, 1, 3, 0, 1],
        [1, 3, 0, 1, 3],
        [3, 0, 1, 3, 0],
        [0, 1, 3, 0, 1],
      ]);
      expect(board.findMatches(), hasLength(5));
    });

    test('empty cells never match', () {
      final board = _board(const [
        [_x, _x, _x, 1, 2],
        [1, 2, 3, 0, 3],
        [2, 3, 0, 1, 0],
        [3, 2, 3, 2, 1],
        [0, 1, 2, 3, 0],
      ]);
      expect(board.findMatches(), isEmpty);
    });
  });

  group('swap', () {
    test('only neighbours inside the board can swap', () {
      final board = _board(_stable);
      expect(board.canSwap((row: 0, column: 0), (row: 0, column: 1)), isTrue);
      expect(board.canSwap((row: 0, column: 0), (row: 1, column: 1)), isFalse);
      expect(board.canSwap((row: 0, column: 0), (row: 0, column: 2)), isFalse);
      expect(board.canSwap((row: 0, column: 4), (row: 0, column: 5)), isFalse);
    });

    test('a swap without a match is rejected and undone', () {
      final board = _board(_stable);
      final before = board.snapshot;
      expect(board.trySwap((row: 4, column: 3), (row: 4, column: 4)), isEmpty);
      expect(board.snapshot, before);
    });

    test('a matching swap resolves to a stable, full board', () {
      final board = _board(_stable);
      final steps = board.trySwap((row: 0, column: 1), (row: 1, column: 1));

      expect(steps, isNotEmpty);
      expect(steps.first.level, 1);
      expect(steps.first.cleared, _cells([(0, 0), (0, 1), (0, 2)]));
      expect(steps.first.falls, isEmpty);
      expect(steps.first.spawns.map((s) => s.startRow), everyElement(-1));
      for (var i = 0; i < steps.length; i++) {
        expect(steps[i].level, i + 1);
      }
      expect(board.findMatches(), isEmpty);
      expect(
        board.snapshot.expand((row) => row),
        everyElement(isNot(MatchBoard.empty)),
      );
    });
  });

  group('resolve', () {
    test('gravity drops pieces above a cleared row and refills the top', () {
      final board = _board(const [
        [0, 1, 2, 3, 0],
        [1, 2, 3, 0, 1],
        [3, 3, 3, 1, 2],
        [2, 0, 1, 2, 3],
        [0, 1, 2, 3, 0],
      ]);
      final step = board.resolve().first;

      expect(step.cleared, _cells([(2, 0), (2, 1), (2, 2)]));
      expect(
        {for (final f in step.falls) (f.from, f.to)},
        {
          for (var c = 0; c < 3; c++) ...{
            ((row: 1, column: c), (row: 2, column: c)),
            ((row: 0, column: c), (row: 1, column: c)),
          },
        },
      );
      expect(
        {for (final s in step.spawns) (s.cell, s.startRow)},
        {for (var c = 0; c < 3; c++) ((row: 0, column: c), -1)},
      );
    });

    test('step score is cleared × points × cascade level', () {
      final board = _board(const [
        [0, 1, 2, 3, 0],
        [1, 2, 3, 0, 1],
        [3, 3, 3, 1, 2],
        [2, 0, 1, 2, 3],
        [0, 1, 2, 3, 0],
      ]);
      final steps = board.resolve();
      expect(steps.first.score(10), 30);
      for (final step in steps) {
        expect(step.score(10), step.cleared.length * 10 * step.level);
      }
    });
  });

  group('shuffle', () {
    test('turns a dead board into a stable one with a move', () {
      final board = _board(const [
        [0, 1, 2, 3, 0],
        [2, 3, 0, 1, 2],
        [0, 1, 2, 3, 0],
        [2, 3, 0, 1, 2],
        [0, 1, 2, 3, 0],
      ]);
      expect(board.findMatches(), isEmpty);
      expect(board.hasAnyMove(), isFalse);

      board.shuffle();

      expect(board.findMatches(), isEmpty);
      expect(board.hasAnyMove(), isTrue);
    });
  });
}
