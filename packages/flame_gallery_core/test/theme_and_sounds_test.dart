import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final class _SoundGame extends GalleryFlameGame {
  _SoundGame() : super(gameId: 'sound') {
    for (final name in GameOverlays.all) {
      overlays.addEntry(name, (_, _) => const SizedBox.shrink());
    }
  }

  Color canvas(Color surface) => resolveBackground(surface);

  @override
  void onRoundStart() {}
}

final class _FakeGameHost extends GalleryGame<_SoundGame> {
  const _FakeGameHost()
    : super(
        strings: const GameStrings.en(title: 'T', instructions: 'I'),
      );

  @override
  String get gameId => 'sound';

  @override
  _SoundGame createGame(ColorScheme colors) => _SoundGame();

  @override
  Widget buildHud(BuildContext context, _SoundGame game) =>
      const Text('custom-hud');
}

void main() {
  group('GameTheme', () {
    testWidgets('themeData drives colors and font is layered on top', (
      tester,
    ) async {
      final custom = ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
      );
      late ThemeData resolved;
      late ColorScheme colors;
      await tester.pumpWidget(
        Builder(
          builder: (context) {
            final theme = GameTheme(themeData: custom, fontFamily: 'Brand');
            resolved = theme.toThemeData(context);
            colors = theme.resolveColors(context);
            return const SizedBox.shrink();
          },
        ),
      );
      expect(colors, custom.colorScheme);
      expect(resolved.textTheme.bodyMedium?.fontFamily, 'Brand');
    });

    test('copyWith clears and keeps background', () {
      const theme = GameTheme(background: GameBackground.color(Colors.red));
      expect(theme.copyWith().background, isA<ColorBackground>());
      expect(theme.copyWith(background: () => null).background, isNull);
    });
  });

  group('sounds', () {
    testWithGame<_SoundGame>('play cues for a round', _SoundGame.new, (
      game,
    ) async {
      final cues = <GameSoundCue>[];
      game
        ..configure(sounds: CallbackSounds(cues.add))
        ..start()
        ..addScore(2)
        ..addScore(-1)
        ..finish();
      expect(cues, [
        GameSoundCue.start,
        GameSoundCue.scoreUp,
        GameSoundCue.penalty,
        GameSoundCue.gameOver,
      ]);
    });

    testWithGame<_SoundGame>('quit stays silent', _SoundGame.new, (game) async {
      final cues = <GameSoundCue>[];
      game
        ..configure(sounds: CallbackSounds(cues.add))
        ..start()
        ..quit();
      expect(cues, [GameSoundCue.start]);
    });

    testWithGame<_SoundGame>(
      'backdrop makes the canvas transparent',
      _SoundGame.new,
      (game) async {
        const surface = Color(0xFF112233);
        expect(game.canvas(surface), surface);
        game.configure(hasBackdrop: true);
        expect(game.canvas(surface), const Color(0x00000000));
      },
    );
  });

  group('GameHostPage overlays', () {
    testWidgets('custom builders replace the defaults', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: GameHostPage(
            game: const _FakeGameHost(),
            immersive: false,
            overlays: GameOverlayBuilders(
              start: (context, ui) => TextButton(
                onPressed: ui.start,
                child: Text('go ${ui.strings.title}'),
              ),
              hud: (context, ui) => ui.hud,
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(find.textContaining('go '), findsOneWidget);
      await tester.tap(find.textContaining('go '));
      await tester.pump();
      await tester.pump();
      expect(find.text('custom-hud'), findsOneWidget);
    });
  });
}
