## Unreleased

- Distance HUD text comes from `GameStrings.distance`.
- `RunnerDifficulty` is now a class with presets and `copyWith`.
- `RunnerSprites.runnerAnimation` / `coinAnimation`. Emits `jump`, `coin`, `hit` sound cues.
- Internal cleanup: core countdown/end-cause/loading helpers; collision and spawn code split into small steps. Images load in parallel.
- `RunnerStatKeys`: const keys for `GameResult.stats`.

## 0.1.0

- Initial release.
