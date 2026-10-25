# flame_gallery_core example

Build your own gallery game: extend `GalleryFlameGame` for gameplay and
`GalleryGame` for the public, brandable description.

```dart
import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flutter/material.dart';

final class TapGame extends GalleryFlameGame {
  TapGame() : super(gameId: TapCounter.id);

  @override
  void onRoundStart() {}

  void tap() => addScore(1);
}

final class TapCounter extends GalleryGame<TapGame> {
  const TapCounter()
    : super(
        strings: const GameStrings.en(
          title: 'Tap Counter',
          instructions: 'Tap as fast as you can.',
        ),
      );

  static const id = 'tap_counter';

  @override
  String get gameId => id;

  @override
  TapGame createGame(ColorScheme colors) => TapGame();

  @override
  Widget buildHud(BuildContext context, TapGame game) =>
      HudScoreChip(score: game.score);
}
```

Open it with `GameHostPage(game: const TapCounter())` or
`FlameGallery.show` from the `flame_gallery` package.
