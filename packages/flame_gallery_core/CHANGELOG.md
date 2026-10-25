## Unreleased

- `GameBackground` (color / gradient / image) via `GameTheme.background`, drawn behind every game.
- `GameTheme.themeData` for full control of menu buttons, cards and text.
- `GameOverlayBuilders` + `GameUi` to replace the start, HUD, pause and game over overlays.
- `GameSounds` / `GameSoundCue` / `CallbackSounds`: sound effect cues without an audio dependency.
- `GameAnimation`: horizontal sprite strips.
- `GameStrings.combo` / `distance` / `accuracy`: overridable in-game value templates (`{value}` placeholder, `GameStrings.fill`).
- `GameEndCause<C>` mixin: end a round with `finishWith(cause)`; the cause is reported as `stats['endedBy']`.
- `RoundCountdown` (time limit → `secondsLeft`) and `Duration.asSeconds`.
- `GalleryFlameGame` creates the game's private `Images(prefix: '')` cache, plus `loadSprites` (parallel) and `addBackground` helpers.
- `HudScoreChip` and `HudTimerChip`.
- `GameStatKeys.endedBy`: const key for the end cause stat.
- `GameHostPage` internals split into a state mixin and per-overlay parts (no public API change).

## 0.1.0

- Initial release.
