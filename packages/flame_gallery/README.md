# Flame Gallery

[![pub package](https://img.shields.io/pub/v/flame_gallery.svg)](https://pub.dev/packages/flame_gallery)
[![CI](https://github.com/VB10/flame_gallery/actions/workflows/ci.yml/badge.svg)](https://github.com/VB10/flame_gallery/actions/workflows/ci.yml)
[![License: MIT](https://img.shields.io/badge/license-MIT-blue.svg)](https://github.com/VB10/flame_gallery/blob/main/LICENSE)

Drop-in, brandable 2D mini games for any Flutter app, built on [Flame](https://flame-engine.org).
One call opens a full screen game; you get the score back.

```dart
final result = await FlameGallery.show(context, game: const FruitSlice());
```

**[Play it in your browser](https://vb10.github.io/flame_gallery/play/)** · [Website](https://vb10.github.io/flame_gallery/) · [GitHub](https://github.com/VB10/flame_gallery)

| Fruit Slice | Ruins Runner | Sweet Swap | Note Rush |
|:---:|:---:|:---:|:---:|
| <img src="https://raw.githubusercontent.com/VB10/flame_gallery/main/packages/flame_gallery/screenshots/fruit_slice.png" width="180"> | <img src="https://raw.githubusercontent.com/VB10/flame_gallery/main/packages/flame_gallery/screenshots/runner.png" width="180"> | <img src="https://raw.githubusercontent.com/VB10/flame_gallery/main/packages/flame_gallery/screenshots/sweet_swap.png" width="180"> | <img src="https://raw.githubusercontent.com/VB10/flame_gallery/main/packages/flame_gallery/screenshots/note_rush.png" width="180"> |
| Swipe to slice, avoid bombs | 3 lanes: swipe, jump, slide | Match three or more | Tap notes on the beat |

## Why

- **One dependency, one call.** `FlameGallery.show` pushes a full screen route with start, pause and game over menus, and completes with a `GameResult`.
- **Brandable without forking.** Colors (`ColorScheme`), font, logo, every text, sprites and rules are config. No colors given → the game follows your app theme.
- **Campaign ready.** Timers, lives, move limits, target scores, seeded boards ("daily challenge") and a result with stats you can turn into coupons or points.
- **Light on your app.** The libraries depend only on `flutter` and `flame`. No state management or codegen packages are forced on you.
- **Testable.** Stable `Semantics` identifiers on every menu button and HUD value (`GalleryKeys`), so Maestro / Patrol / integration tests can drive the games.

## Install

```bash
flutter pub add flame_gallery
```

Each game is also its own package (`flame_gallery_slice`, `flame_gallery_runner`, `flame_gallery_match`, `flame_gallery_rhythm`) if you only want one.

## Usage

```dart
import 'package:flame_gallery/flame_gallery.dart';

final result = await FlameGallery.show(
  context,
  game: FruitSlice(
    config: const SliceConfig(
      timeLimit: Duration(seconds: 30),
      bomb: null, // no bombs in this campaign
    ),
    theme: GameTheme(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFF00897B),
        brightness: Brightness.dark,
      ),
      logo: const AssetImage('assets/brand_logo.png'),
    ),
    strings: FruitSlice.stringsTr.copyWith(
      title: 'Summer Campaign',
      instructions: 'Slice as many fruits as you can in 30 seconds!',
    ),
  ),
  onEvent: (event) => analytics.log('$event'),
);

if (result case GameResult(isCompleted: true, :final score) when score >= 50) {
  grantCoupon();
}
```

### The games

| Game | Class | Config highlights |
|---|---|---|
| Fruit Slice | `FruitSlice` | `timeLimit`, `lives`, `items` (your own sprites, points, juice color), `bomb`, `bombChance`, `difficulty`, `background` |
| Ruins Runner | `EndlessRunner` | `timeLimit`, `lives`, `coinValue`, `difficulty`, `sprites`, `background` |
| Sweet Swap | `SweetSwap` | `rows`, `columns`, `pieces`, `moveLimit`, `timeLimit`, `targetScore`, `seed` |
| Note Rush | `NoteRush` | `song` (beat map), `difficulty`, `missLimit`, plus a pluggable `RhythmAudio` so you play music with your own audio stack |

Every game ships English and Turkish texts (`stringsEn`, `stringsTr`); override any of them with `copyWith`.

### Results and events

```dart
GameResult(
  gameId: 'fruit_slice',
  score: 42,
  reason: GameEndReason.completed, // or quit
  playTime: Duration(seconds: 30),
  stats: {'sliced': 40, 'maxCombo': 4, 'endedBy': 'timeUp'},
);
```

`onEvent` receives `GameStarted`, `GameScoreChanged`, `GamePaused`, `GameResumed` and `GameFinished`. `GameResult.toJson()` gives a flat map for analytics or a platform channel.

### Your own assets

Use `GameAsset('assets/my_fruit.png')` for files in your app bundle:

```dart
FruitSlice(
  config: SliceConfig(
    items: const [
      SliceItem(sprite: GameAsset('assets/products/can.png'), juiceColor: Color(0xFFE53935), points: 2),
      SliceItem.orange,
    ],
  ),
);
```

### System UI

Games run in immersive mode (system bars hidden) and restore `SystemUiMode.edgeToEdge` on close. Pass `immersive: false` to `FlameGallery.show` if your app manages system UI itself.

## Testing

Menu buttons and HUD values carry `Semantics(identifier:)` values from `GalleryKeys` (`gallery_start_button`, `gallery_pause_button`, `gallery_final_score`, `gallery_hud_score`, ...) and per game keys (`RunnerKeys`, `MatchKeys`, `RhythmKeys`). The repository has a Maestro suite that plays every game on iOS and Android: [apps/example/maestro](https://github.com/VB10/flame_gallery/tree/main/apps/example/maestro).

## Build your own game

Extend `GalleryFlameGame` (gameplay) and `GalleryGame` (public description) from [flame_gallery_core](https://pub.dev/packages/flame_gallery_core); the host page, menus, pause handling and results come for free.

## License

MIT
