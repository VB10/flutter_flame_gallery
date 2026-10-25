import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_slice/flame_gallery_slice.dart';
import 'package:flame_gallery_slice/src/component/slice_item_component.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

SliceGame _game({
  SliceConfig config = const SliceConfig(),
  math.Random? random,
}) {
  final game = SliceGame(
    config: config,
    colors: ColorScheme.fromSeed(seedColor: Colors.orange),
    gameId: FruitSlice.id,
    random: random ?? math.Random(1),
  );
  for (final name in GameOverlays.all) {
    game.overlays.addEntry(name, (_, _) => const SizedBox.shrink());
  }
  return game;
}

List<SliceItemComponent> _items(SliceGame game) =>
    game.children.whereType<SliceItemComponent>().toList();

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithGame<SliceGame>('spawner throws items once playing', _game, (
    game,
  ) async {
    game.start();
    for (var i = 0; i < 60; i++) {
      game.update(1 / 60);
    }
    await game.ready();
    expect(_items(game), isNotEmpty);
  });

  testWithGame<SliceGame>(
    'swiping through a fruit scores its points',
    () => _game(config: const SliceConfig(bomb: null)),
    (game) async {
      game
        ..start()
        ..spawnWave(1);
      await game.ready();
      final target = _items(game).single;

      game
        ..beginStroke(target.position - Vector2(80, 0))
        ..swipe(
          target.position - Vector2(80, 0),
          target.position + Vector2(80, 0),
        )
        ..endStroke();
      await game.ready();

      expect(game.score.value, target.item!.points);
      expect(_items(game), isEmpty);
    },
  );

  final spawnRandom = _CountingRandom();
  testWithGame<SliceGame>(
    'slice effects never draw from the spawn random',
    () => _game(config: const SliceConfig(bomb: null), random: spawnRandom),
    (game) async {
      game
        ..start()
        ..spawnWave(1);
      await game.ready();
      final target = _items(game).single;
      final drawsBefore = spawnRandom.draws;

      game.swipe(
        target.position - Vector2(80, 0),
        target.position + Vector2(80, 0),
      );
      await game.ready();

      expect(game.score.value, greaterThan(0));
      expect(spawnRandom.draws, drawsBefore);
    },
  );

  testWithGame<SliceGame>(
    'slicing a bomb ends the round',
    () => _game(config: const SliceConfig(bombChance: 1)),
    (game) async {
      game
        ..start()
        ..spawnWave(1);
      await game.ready();
      final bomb = _items(game).firstWhere((c) => c.isBomb);

      game.swipe(
        bomb.position - Vector2(80, 0),
        bomb.position + Vector2(80, 0),
      );

      expect(game.phase.value, GamePhase.over);
      expect(game.result?.stats[GameStatKeys.endedBy], SliceEndCause.bomb.name);
    },
  );

  testWithGame<SliceGame>(
    'time limit ends the round',
    () => _game(
      config: const SliceConfig(timeLimit: Duration(seconds: 1), bomb: null),
    ),
    (game) async {
      game
        ..start()
        ..update(0.6)
        ..update(0.6);
      expect(game.phase.value, GamePhase.over);
      expect(
        game.result?.stats[GameStatKeys.endedBy],
        SliceEndCause.timeUp.name,
      );
    },
  );

  testWithGame<SliceGame>(
    'missing fruits costs lives until game over',
    () =>
        _game(config: const SliceConfig(timeLimit: null, lives: 2, bomb: null)),
    (game) async {
      game
        ..start()
        ..onItemMissed();
      expect(game.lives.value, 1);
      game.onItemMissed();
      expect(game.phase.value, GamePhase.over);
      expect(
        game.result?.stats[GameStatKeys.endedBy],
        SliceEndCause.outOfLives.name,
      );
    },
  );
}

final class _CountingRandom implements math.Random {
  final math.Random _inner = math.Random(1);
  int draws = 0;

  @override
  bool nextBool() {
    draws++;
    return _inner.nextBool();
  }

  @override
  double nextDouble() {
    draws++;
    return _inner.nextDouble();
  }

  @override
  int nextInt(int max) {
    draws++;
    return _inner.nextInt(max);
  }
}
