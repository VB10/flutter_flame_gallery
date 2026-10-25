import 'dart:math' as math;

import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_runner/flame_gallery_runner.dart';
import 'package:flame_gallery_runner/src/component/track_object.dart';
import 'package:flame_gallery_runner/src/logic/obstacle_row_planner.dart';
import 'package:flame_gallery_runner/src/logic/runner_types.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

RunnerGame _game({RunnerConfig config = const RunnerConfig()}) {
  final game = RunnerGame(
    config: config,
    colors: ColorScheme.fromSeed(seedColor: Colors.brown),
    gameId: EndlessRunner.id,
    random: math.Random(1),
  );
  for (final name in GameOverlays.all) {
    game.overlays.addEntry(name, (_, _) => const SizedBox.shrink());
  }
  return game;
}

List<ObstacleComponent> _obstacles(RunnerGame game) =>
    game.children.whereType<ObstacleComponent>().toList();

/// A row with a single [kind] obstacle in [lane].
RunnerRow _rowWith(ObstacleKind kind, int lane) => RunnerRow(
  obstacles: List<ObstacleKind?>.generate(3, (i) => i == lane ? kind : null),
);

void _step(RunnerGame game, {double seconds = 0.2, double dt = 1 / 60}) {
  for (var t = 0.0; t < seconds; t += dt) {
    game.update(dt);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithGame<RunnerGame>('rows spawn once playing and score grows', _game, (
    game,
  ) async {
    game.start();
    _step(game, seconds: 2);
    await game.ready();
    expect(_obstacles(game), isNotEmpty);
    expect(game.distance.value, greaterThan(0));
    expect(game.score.value, greaterThanOrEqualTo(game.distance.value));
  });

  testWithGame<RunnerGame>('swipes change lane and pose', _game, (game) async {
    game
      ..start()
      ..onSwipe(SwipeDirection.left);
    expect(game.motion.lane, 0);
    game.onSwipe(SwipeDirection.up);
    expect(game.motion.pose, PlayerPose.jumping);
  });

  testWithGame<RunnerGame>('a block in the player lane ends the round', _game, (
    game,
  ) async {
    game
      ..start()
      ..spawnRow(_rowWith(ObstacleKind.block, 1), y: game.layout.playerY);
    await game.ready();
    _step(game, seconds: 0.05);

    expect(game.phase.value, GamePhase.over);
    expect(
      game.result?.stats[GameStatKeys.endedBy],
      RunnerEndCause.outOfLives.name,
    );
  });

  testWithGame<RunnerGame>('a block in another lane is harmless', _game, (
    game,
  ) async {
    game
      ..start()
      ..spawnRow(_rowWith(ObstacleKind.block, 0), y: game.layout.playerY);
    await game.ready();
    _step(game, seconds: 0.05);
    expect(game.phase.value, GamePhase.playing);
  });

  testWithGame<RunnerGame>('jumping clears a low barrier', _game, (game) async {
    game
      ..start()
      ..onSwipe(SwipeDirection.up)
      ..spawnRow(_rowWith(ObstacleKind.lowBarrier, 1), y: game.layout.playerY);
    await game.ready();
    _step(game, seconds: 0.05);
    expect(game.phase.value, GamePhase.playing);
  });

  testWithGame<RunnerGame>(
    'extra lives absorb a hit with invulnerability',
    () => _game(config: const RunnerConfig(lives: 2)),
    (game) async {
      game
        ..start()
        ..spawnRow(_rowWith(ObstacleKind.block, 1), y: game.layout.playerY);
      await game.ready();
      _step(game, seconds: 0.05);
      expect(game.phase.value, GamePhase.playing);
      expect(game.lives.value, 1);
      expect(game.motion.isInvulnerable, isTrue);
    },
  );

  testWithGame<RunnerGame>('coins in the player lane are collected', _game, (
    game,
  ) async {
    game
      ..start()
      ..spawnRow(
        const RunnerRow(obstacles: [null, null, null], coinLane: 1),
        y: game.layout.playerY,
      );
    await game.ready();
    _step(game, seconds: 0.05);
    expect(game.coins.value, greaterThan(0));
    expect(game.score.value, greaterThanOrEqualTo(5));
  });

  testWithGame<RunnerGame>(
    'time limit ends the round',
    () => _game(config: const RunnerConfig(timeLimit: Duration(seconds: 1))),
    (game) async {
      game.start();
      for (var i = 0; i < 40; i++) {
        game.update(1 / 30);
      }
      expect(game.phase.value, GamePhase.over);
      expect(
        game.result?.stats[GameStatKeys.endedBy],
        RunnerEndCause.timeUp.name,
      );
    },
  );

  testWithGame<RunnerGame>(
    'a jank frame is clamped so obstacles cannot tunnel',
    _game,
    (game) async {
      game
        ..start()
        ..update(1);
      expect(game.playTime.inMilliseconds, lessThanOrEqualTo(34));
    },
  );
}
