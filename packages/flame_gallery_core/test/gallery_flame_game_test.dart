import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

base class _FakeGame extends GalleryFlameGame {
  _FakeGame() : super(gameId: 'fake') {
    for (final name in GameOverlays.all) {
      overlays.addEntry(name, (_, _) => const SizedBox.shrink());
    }
  }

  int rounds = 0;

  @override
  void onRoundStart() => rounds++;

  @override
  Map<String, Object> collectStats() => {'rounds': rounds};
}

void main() {
  testWithGame<_FakeGame>(
    'starts in ready with the start overlay',
    _FakeGame.new,
    (game) async {
      expect(game.phase.value, GamePhase.ready);
      expect(game.overlays.activeOverlays, [GameOverlays.start]);
    },
  );

  testWithGame<_FakeGame>('ignores score outside of play', _FakeGame.new, (
    game,
  ) async {
    game.addScore(5);
    expect(game.score.value, 0);
  });

  testWithGame<_FakeGame>(
    'full round emits events and a result',
    _FakeGame.new,
    (game) async {
      final events = <GameEvent>[];
      game.events.listen(events.add);

      game
        ..start()
        ..addScore(3)
        ..update(1.5)
        ..pause()
        ..resume();
      final result = game.finish();
      await Future<void>.delayed(Duration.zero);

      expect(result?.score, 3);
      expect(result?.reason, GameEndReason.completed);
      expect(result?.playTime, const Duration(milliseconds: 1500));
      expect(result?.stats, {'rounds': 1});
      expect(game.phase.value, GamePhase.over);
      expect(game.overlays.activeOverlays, [GameOverlays.gameOver]);
      expect(events.map((e) => e.runtimeType), [
        GameStarted,
        GameScoreChanged,
        GamePaused,
        GameResumed,
        GameFinished,
      ]);
    },
  );

  testWithGame<_FakeGame>('pause shows hud and pause overlays', _FakeGame.new, (
    game,
  ) async {
    game
      ..start()
      ..pause();
    expect(game.paused, isTrue);
    expect(game.overlays.activeOverlays, [
      GameOverlays.hud,
      GameOverlays.pause,
    ]);
  });

  testWithGame<_FakeGame>('play again resets score and round', _FakeGame.new, (
    game,
  ) async {
    game
      ..start()
      ..addScore(4)
      ..finish()
      ..start();
    expect(game.score.value, 0);
    expect(game.rounds, 2);
    expect(game.result, isNull);
  });

  testWithGame<_FakeGame>(
    'engine pauses shortly after game over and resumes on play again',
    _FakeGame.new,
    (game) async {
      game
        ..start()
        ..finish()
        ..update(0.5);
      expect(game.paused, isFalse);
      game.update(0.5);
      expect(game.paused, isTrue);

      game.start();
      expect(game.paused, isFalse);
      expect(game.phase.value, GamePhase.playing);
    },
  );

  testWithGame<_FakeGame>(
    'quit ends the round without the game over panel',
    _FakeGame.new,
    (game) async {
      final events = <GameEvent>[];
      game.events.listen(events.add);
      game
        ..start()
        ..addScore(2);
      final result = game.quit();

      expect(result?.reason, GameEndReason.quit);
      expect(result?.score, 2);
      expect(game.phase.value, GamePhase.over);
      expect(game.overlays.isActive(GameOverlays.gameOver), isFalse);
      expect(events.last, isA<GameFinished>());
    },
  );

  testWithGame<_FakeGame>('finish before start is a no-op', _FakeGame.new, (
    game,
  ) async {
    expect(game.finish(reason: GameEndReason.quit), isNull);
    expect(game.phase.value, GamePhase.ready);
  });

  group('GameEndCause', () {
    testWithGame<_CausedGame>(
      'reports the cause after the game stats',
      _CausedGame.new,
      (game) async {
        game
          ..start()
          ..end(_Cause.timeUp);
        expect(game.result?.stats, {
          'rounds': 1,
          GameStatKeys.endedBy: 'timeUp',
        });
        expect(game.endCause, _Cause.timeUp);
      },
    );

    testWithGame<_CausedGame>(
      'a quit after a caused round reports quit',
      _CausedGame.new,
      (game) async {
        game
          ..start()
          ..end(_Cause.timeUp)
          ..start();
        expect(game.endCause, isNull);
        expect(game.quit()?.stats[GameStatKeys.endedBy], 'quit');
      },
    );
  });
}

enum _Cause { timeUp }

final class _CausedGame extends _FakeGame with GameEndCause<_Cause> {
  void end(_Cause cause) => finishWith(cause);
}
