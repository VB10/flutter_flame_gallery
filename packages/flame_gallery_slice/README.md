# flame_gallery_slice

Fruit Slice for [Flame Gallery](https://pub.dev/packages/flame_gallery): Swipe to slice fruits, chain combos (3+ in one stroke) and avoid bombs.

<img src="https://raw.githubusercontent.com/VB10/flame_gallery/main/packages/flame_gallery/screenshots/fruit_slice.png" width="240" alt="Fruit Slice">

Most apps should depend on [`flame_gallery`](https://pub.dev/packages/flame_gallery) and call
`FlameGallery.show(context, game: const FruitSlice())`. Use this package directly if you only want this game.

## Configure

```dart
FruitSlice(
  config: const SliceConfig(
    timeLimit: Duration(seconds: 60), // null → no timer
    lives: null,                      // e.g. 3 for survival mode
    items: SliceItem.fruits,          // or your own SliceItem(sprite: GameAsset(...))
    bomb: SliceItem.bomb,             // null → no bombs
    bombChance: 0.12,
    difficulty: SliceDifficulty.normal,
  ),
)
```

Texts: `FruitSlice.stringsEn`, `FruitSlice.stringsTr`, or your own via `copyWith`.
Colors, font and logo: `theme: GameTheme(...)`.

## Result stats

`sliced`, `maxCombo`, `endedBy` (`timeUp`, `outOfLives`, `bomb`, `quit`).

## License

MIT
