# flame_gallery_match

**Sweet Swap** for [Flame Gallery](https://pub.dev/packages/flame_gallery): a match-three puzzle. Swap neighbouring sweets to line up three or more, set off cascades and reach the target before the moves run out.

<img src="https://raw.githubusercontent.com/VB10/flutter_flame_gallery/main/site/images/sweet_swap.gif" width="240" alt="Sweet Swap gameplay">

Most apps depend on [`flame_gallery`](https://pub.dev/packages/flame_gallery) and call
`FlameGallery.show(context, game: const SweetSwap())`. Depend on this package directly if you only need this game.

## How to play

- **Drag** a sweet toward a neighbour, or **tap** one and then its neighbour, to swap them.
- A swap that lines up three or more of the same sweet clears them; the rest fall and new sweets drop in. A swap that matches nothing bounces back and costs no move.
- Each cleared sweet is worth `pointsPerPiece` × the cascade level: the first clear ×1, the chain reaction after it ×2, then ×3...
- The round ends when the moves run out (default 20), the optional timer ends, or `targetScore` is reached.
- The six sweets differ in colour **and** shape (drop, wrapped sweet, jelly, star, heart, triangle), so the board reads without colour vision.

## How it works

- **The board is pure Dart.** `MatchBoard` (`src/logic/match_board.dart`) finds runs, applies gravity, refills and records every cascade as a `CascadeStep` (cleared cells, falls, spawns, level). Boards are generated without ready-made matches and always with at least one valid move; when no move is left the board reshuffles.
- **Animation is a stage queue.** The Flame layer turns the steps into stages (swap, clear, fall, shuffle, settle); each stage is a function that starts its effects and returns how long they take. Input is locked until the final settle stage.
- **Rounds end after the cascade.** Move limits, target scores and even time-up are checked in the settle stage, so points the board has already awarded are never lost mid-animation.
- **Seeded boards**: `MatchConfig(seed: ...)` gives every player the same board and refills — a "daily puzzle".
- Pieces snap to their cells when the screen is resized or rotated mid-animation.

## Configure

```dart
SweetSwap(
  config: const MatchConfig(
    rows: 8,
    columns: 8,         // 5..10
    moveLimit: 20,      // and/or timeLimit
    targetScore: 1500,  // reaching it ends the round as a win
    seed: 20261024,     // same board for every player
  ),
)
```

Configs are immutable; nullable fields are cleared through `copyWith` with a getter: `config.copyWith(targetScore: () => null)`.

## Make it yours

```dart
SweetSwap(
  theme: GameTheme(
    colorScheme: ColorScheme.fromSeed(seedColor: brandColor, brightness: Brightness.dark),
    logo: const AssetImage('assets/logo.png'),
  ),
  strings: SweetSwap.stringsTr.copyWith(title: 'Summer Campaign'),
)
```

Without a `colorScheme` the game follows your app theme. Texts ship in English (`SweetSwap.stringsEn`, default) and Turkish (`SweetSwap.stringsTr`).

## Result stats

`movesUsed`, `maxCascade`, `endedBy` (`outOfMoves`, `timeUp`, `target`, `quit`).

## UI test ids

Menus and HUD values carry `Semantics(identifier:)` ids for Maestro, Patrol or integration tests: `GalleryKeys` from `flame_gallery_core` (`gallery_start_button`, `gallery_pause_button`, `gallery_final_score`, `gallery_hud_score`, ...), plus `MatchKeys.hudMoves` and `MatchKeys.hudTarget`.

## License

MIT
