# flame_gallery_slice

**Fruit Slice** for [Flame Gallery](https://pub.dev/packages/flame_gallery): swipe across the screen to slice fruit, chain combos and stay away from the bombs.

<img src="https://raw.githubusercontent.com/VB10/flutter_flame_gallery/main/site/images/fruit_slice.gif" width="240" alt="Fruit Slice gameplay">

Most apps depend on [`flame_gallery`](https://pub.dev/packages/flame_gallery) and call
`FlameGallery.show(context, game: const FruitSlice())`. Depend on this package directly if you only need this game.

## How to play

- Fruit is thrown up from the bottom of the screen. Swipe through it to slice it; every fruit is worth its `points` (watermelon 2, the others 1).
- Slice three or more in **one stroke** for a combo: the stroke earns a bonus equal to the number of fruits sliced.
- Touching a **bomb** ends the round. Letting fruit fall costs a life when `lives` is set.
- The round ends when the timer runs out (default 60 s), the lives are gone, or a bomb is hit.

## How it works

- **Throws are planned from physics** (`src/logic/launch_planner.dart`). The planner picks an apex between 15 % and 45 % of the screen height, uses gravity `g = 1.2 · height · speed²` and launches with `v = √(2 · g · h)`, so every fruit peaks on screen and higher difficulty only makes it faster.
- **Slicing is a segment test.** Each drag update is a line segment checked against every fruit's circle (`segmentHitsCircle`), so a fast swipe that jumps across a fruit between two frames still slices it. Only one finger is tracked at a time.
- **Halves come from the sprite itself**: the image is split with `Sprite(srcPosition:, srcSize:)` and the halves fly apart perpendicular to the swipe.
- **Effects**: a tapering blade trail with a blurred glow, juice bursts from `GalleryBurst`, combo labels from `FloatingLabel` with a `TextPaint` built once.
- Waves grow from 1 to `maxWaveSize` items while the spawn interval shrinks over `rampSeconds` (`SliceDifficulty`).

## Configure

```dart
FruitSlice(
  config: const SliceConfig(
    timeLimit: Duration(seconds: 60), // null → no timer
    lives: null,                      // e.g. 3 for survival mode
    items: SliceItem.fruits,          // or your own SliceItem(sprite: GameAsset('assets/can.png'), ...)
    bomb: SliceItem.bomb,             // null → no bombs
    bombChance: 0.12,
    difficulty: SliceDifficulty.normal,
  ),
)
```

Configs are immutable; nullable fields are cleared through `copyWith` with a getter: `config.copyWith(bomb: () => null)`.

## Make it yours

```dart
FruitSlice(
  theme: GameTheme(
    colorScheme: ColorScheme.fromSeed(seedColor: brandColor, brightness: Brightness.dark),
    logo: const AssetImage('assets/logo.png'),
  ),
  strings: FruitSlice.stringsTr.copyWith(title: 'Summer Campaign'),
)
```

Without a `colorScheme` the game follows your app theme. Texts ship in English (`FruitSlice.stringsEn`, default) and Turkish (`FruitSlice.stringsTr`).

## Result stats

`sliced`, `maxCombo`, `endedBy` (`timeUp`, `outOfLives`, `bomb`, `quit`).

## UI test ids

Menus and HUD values carry `Semantics(identifier:)` ids for Maestro, Patrol or integration tests: `GalleryKeys` from `flame_gallery_core` (`gallery_start_button`, `gallery_pause_button`, `gallery_final_score`, `gallery_hud_score`, ...).

## License

MIT
