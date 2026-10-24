# flame_gallery_match example

```dart
import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_match/flame_gallery_match.dart';
import 'package:flutter/material.dart';

Future<GameResult?> play(BuildContext context) => Navigator.of(context).push(
  MaterialPageRoute<GameResult>(
    fullscreenDialog: true,
    builder: (_) => const GameHostPage(
      game: SweetSwap(config: MatchConfig(moveLimit: 15, targetScore: 1000)),
    ),
  ),
);
```

Most apps use the [flame_gallery](https://pub.dev/packages/flame_gallery)
facade instead: `FlameGallery.show(context, game: const SweetSwap())`.
