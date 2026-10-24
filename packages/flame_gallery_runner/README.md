# flame_gallery_runner

Ruins Runner for [Flame Gallery](https://pub.dev/packages/flame_gallery): Three-lane endless runner: swipe left/right to change lanes, up to jump over logs, down to slide under arches. Collect coins; the world speeds up.

<img src="https://raw.githubusercontent.com/VB10/flame_gallery/main/packages/flame_gallery/screenshots/runner.png" width="240" alt="Ruins Runner">

Most apps should depend on [`flame_gallery`](https://pub.dev/packages/flame_gallery) and call
`FlameGallery.show(context, game: const EndlessRunner())`. Use this package directly if you only want this game.

## Configure

```dart
EndlessRunner(
  config: const RunnerConfig(
    timeLimit: null, // endless; e.g. Duration(seconds: 60)
    lives: 1,
    coinValue: 5,
    difficulty: RunnerDifficulty.normal,
    sprites: RunnerSprites(), // runner, coin, block, lowBarrier, highBarrier
  ),
)
```

Texts: `EndlessRunner.stringsEn`, `EndlessRunner.stringsTr`, or your own via `copyWith`.
Colors, font and logo: `theme: GameTheme(...)`.

## Result stats

`distance` (m), `coins`, `endedBy` (`outOfLives`, `timeUp`, `quit`).

## License

MIT
