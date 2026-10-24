# flame_gallery_runner

**Ruins Runner** for [Flame Gallery](https://pub.dev/packages/flame_gallery): a three-lane endless runner seen from above. Dodge stones, jump logs, slide under arches and collect coins while the ruins speed up.

<img src="https://raw.githubusercontent.com/VB10/flutter_flame_gallery/main/site/images/runner.gif" width="240" alt="Ruins Runner gameplay">

Most apps depend on [`flame_gallery`](https://pub.dev/packages/flame_gallery) and call
`FlameGallery.show(context, game: const EndlessRunner())`. Depend on this package directly if you only need this game.

## How to play

- **Swipe left / right** to change lane, **swipe up** to jump, **swipe down** to slide.
- **Stone blocks** fill a lane: change lane. **Low logs**: jump over them. **High arches**: slide under them.
- Every metre run is worth a point; every coin adds `coinValue` (default 5).
- A hit costs a life (default 1) and gives a short blinking invulnerability. The round ends when the lives are gone or the optional timer runs out.

## How it works

- **The world moves, the runner stays.** Rows of obstacles and coins scroll toward the player; speed ramps from `startSpeed` to `maxSpeed` over `rampSeconds` (`RunnerDifficulty`).
- **The simulated step is clamped to 1/30 s.** Flame does not cap `dt`, so a single jank frame could carry an obstacle straight through the hit window; with the clamp, even top speed moves less than the window per step.
- **Every row is passable.** `ObstacleRowPlanner` (`src/logic/`) places 1–3 obstacles with at most two blocks and puts coin lines only in free lanes. The guarantee is unit tested over 50 seeds × 200 rows.
- **Collisions are a rule table**: `RunnerRules.collides(kind, pose)` — a block always hits its lane, a log hits unless jumping, an arch hits unless sliding. A jump can cancel a slide and vice versa, so back-to-back rows that need opposite moves stay survivable at top speed.
- Swipes are read once per drag after a short distance threshold; extra fingers are ignored.

## Configure

```dart
EndlessRunner(
  config: const RunnerConfig(
    timeLimit: null,           // endless; e.g. Duration(seconds: 60) for campaigns
    lives: 1,
    coinValue: 5,
    difficulty: RunnerDifficulty.normal,
    sprites: RunnerSprites(),  // runner, coin, block, lowBarrier, highBarrier
  ),
)
```

Configs are immutable; nullable fields are cleared through `copyWith` with a getter: `config.copyWith(timeLimit: () => null)`.

## Make it yours

```dart
EndlessRunner(
  theme: GameTheme(
    colorScheme: ColorScheme.fromSeed(seedColor: brandColor, brightness: Brightness.dark),
    logo: const AssetImage('assets/logo.png'),
  ),
  strings: EndlessRunner.stringsTr.copyWith(title: 'Summer Campaign'),
)
```

Without a `colorScheme` the game follows your app theme. Texts ship in English (`EndlessRunner.stringsEn`, default) and Turkish (`EndlessRunner.stringsTr`).

## Result stats

`distance` (metres), `coins`, `endedBy` (`outOfLives`, `timeUp`, `quit`).

## UI test ids

Menus and HUD values carry `Semantics(identifier:)` ids for Maestro, Patrol or integration tests: `GalleryKeys` from `flame_gallery_core` (`gallery_start_button`, `gallery_pause_button`, `gallery_final_score`, `gallery_hud_score`, ...), plus `RunnerKeys.hudCoins` and `RunnerKeys.hudDistance`.

## License

MIT
