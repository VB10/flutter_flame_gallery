# flame_gallery_runner example

```dart
import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_runner/flame_gallery_runner.dart';
import 'package:flutter/material.dart';

Future<GameResult?> play(BuildContext context) => Navigator.of(context).push(
  MaterialPageRoute<GameResult>(
    fullscreenDialog: true,
    builder: (_) => const GameHostPage(
      game: EndlessRunner(config: RunnerConfig(lives: 3)),
    ),
  ),
);
```

Most apps use the [flame_gallery](https://pub.dev/packages/flame_gallery)
facade instead: `FlameGallery.show(context, game: const EndlessRunner())`.
