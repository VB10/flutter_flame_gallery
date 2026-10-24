# flame_gallery_match

Sweet Swap for [Flame Gallery](https://pub.dev/packages/flame_gallery): Match-three puzzle: swap neighbouring sweets (drag or tap-tap) to line up 3 or more. Cascades multiply points; boards reshuffle when no move is left.

<img src="https://raw.githubusercontent.com/VB10/flame_gallery/main/packages/flame_gallery/screenshots/sweet_swap.png" width="240" alt="Sweet Swap">

Most apps should depend on [`flame_gallery`](https://pub.dev/packages/flame_gallery) and call
`FlameGallery.show(context, game: const SweetSwap())`. Use this package directly if you only want this game.

## Configure

```dart
SweetSwap(
  config: const MatchConfig(
    rows: 8,
    columns: 8,
    moveLimit: 20,      // and/or timeLimit
    targetScore: 1500,  // reaching it ends the round as a win
    seed: 20261024,     // same board for every player ("daily")
  ),
)
```

Texts: `SweetSwap.stringsEn`, `SweetSwap.stringsTr`, or your own via `copyWith`.
Colors, font and logo: `theme: GameTheme(...)`.

## Result stats

`movesUsed`, `maxCascade`, `endedBy` (`outOfMoves`, `timeUp`, `target`, `quit`).

## License

MIT
