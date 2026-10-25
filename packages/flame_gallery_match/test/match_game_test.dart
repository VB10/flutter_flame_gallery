import 'dart:math' as math;

import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_match/flame_gallery_match.dart';
import 'package:flame_gallery_match/src/logic/cell.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const _stable = [
  [0, 1, 0, 2, 3],
  [1, 0, 2, 3, 1],
  [2, 3, 1, 0, 2],
  [3, 2, 3, 1, 0],
  [0, 1, 2, 3, 1],
];

const Cell _validA = (row: 0, column: 1);
const Cell _validB = (row: 1, column: 1);
const Cell _invalidA = (row: 4, column: 3);
const Cell _invalidB = (row: 4, column: 4);

MatchGame Function() _game({
  int? moveLimit = 5,
  Duration? timeLimit,
  int? targetScore,
}) => () {
  final game = MatchGame(
    config: MatchConfig(
      rows: 5,
      columns: 5,
      pieces: MatchPiece.sweets.take(4).toList(),
      moveLimit: moveLimit,
      timeLimit: timeLimit,
      targetScore: targetScore,
    ),
    colors: ColorScheme.fromSeed(seedColor: Colors.pink),
    gameId: SweetSwap.id,
    random: math.Random(3),
    initialGrid: _stable,
  );
  for (final name in GameOverlays.all) {
    game.overlays.addEntry(name, (_, _) => const SizedBox.shrink());
  }
  return game;
};

Future<void> _settle(MatchGame game) async {
  for (var i = 0; i < 600 && game.isBusy; i++) {
    game.update(1 / 60);
  }
  await game.ready();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithGame<MatchGame>('valid swap scores and costs a move', _game(), (
    game,
  ) async {
    game
      ..start()
      ..requestSwap(_validA, _validB);
    expect(game.isBusy, isTrue);
    await _settle(game);

    expect(game.isBusy, isFalse);
    expect(game.score.value, greaterThanOrEqualTo(30));
    expect(game.movesLeft.value, 4);
    expect(game.phase.value, GamePhase.playing);
    expect(game.board.findMatches(), isEmpty);
  });

  testWithGame<MatchGame>('invalid swap bounces back for free', _game(), (
    game,
  ) async {
    game
      ..start()
      ..requestSwap(_invalidA, _invalidB);
    await _settle(game);

    expect(game.score.value, 0);
    expect(game.movesLeft.value, 5);
    expect(game.board.snapshot, _stable);
  });

  testWithGame<MatchGame>('input is ignored before start', _game(), (
    game,
  ) async {
    game.requestSwap(_validA, _validB);
    expect(game.isBusy, isFalse);
    expect(game.board.snapshot, _stable);
  });

  testWithGame<MatchGame>(
    'last move ends the round once cascades settle',
    _game(moveLimit: 1),
    (game) async {
      game
        ..start()
        ..requestSwap(_validA, _validB);
      expect(game.phase.value, GamePhase.playing);
      await _settle(game);

      expect(game.phase.value, GamePhase.over);
      expect(
        game.result?.stats[GameStatKeys.endedBy],
        MatchEndCause.outOfMoves.name,
      );
      expect(game.result?.stats[MatchStatKeys.movesUsed], 1);
    },
  );

  testWithGame<MatchGame>(
    'reaching the target score wins early',
    _game(targetScore: 10),
    (game) async {
      game
        ..start()
        ..requestSwap(_validA, _validB);
      await _settle(game);

      expect(game.phase.value, GamePhase.over);
      expect(
        game.result?.stats[GameStatKeys.endedBy],
        MatchEndCause.target.name,
      );
    },
  );

  testWithGame<MatchGame>(
    'time limit ends the round',
    _game(moveLimit: null, timeLimit: const Duration(seconds: 1)),
    (game) async {
      expect(game.secondsLeft.value, 1);
      game
        ..start()
        ..update(0.6)
        ..update(0.6);

      expect(game.phase.value, GamePhase.over);
      expect(
        game.result?.stats[GameStatKeys.endedBy],
        MatchEndCause.timeUp.name,
      );
    },
  );

  testWithGame<MatchGame>(
    'time running out mid cascade keeps the cascade points',
    _game(moveLimit: null, timeLimit: const Duration(seconds: 1)),
    (game) async {
      game
        ..start()
        ..update(0.95)
        ..requestSwap(_validA, _validB)
        ..update(0.1);
      expect(game.phase.value, GamePhase.playing);

      await _settle(game);

      expect(game.phase.value, GamePhase.over);
      expect(
        game.result?.stats[GameStatKeys.endedBy],
        MatchEndCause.timeUp.name,
      );
      expect(game.result?.score, greaterThan(0));
    },
  );

  testWithGame<MatchGame>('play again restores the board and moves', _game(), (
    game,
  ) async {
    game
      ..start()
      ..requestSwap(_validA, _validB);
    await _settle(game);
    game
      ..finish()
      ..start();

    expect(game.score.value, 0);
    expect(game.movesLeft.value, 5);
    expect(game.board.snapshot, _stable);
  });

  testWithGame<MatchGame>('a seed gives the same board every round', _seeded, (
    game,
  ) async {
    game.start();
    final first = game.board.snapshot;
    game
      ..finish()
      ..start();
    expect(game.board.snapshot, first);
  });
}

MatchGame _seeded() {
  final game = MatchGame(
    config: const MatchConfig(seed: 42),
    colors: ColorScheme.fromSeed(seedColor: Colors.pink),
    gameId: SweetSwap.id,
  );
  for (final name in GameOverlays.all) {
    game.overlays.addEntry(name, (_, _) => const SizedBox.shrink());
  }
  return game;
}
