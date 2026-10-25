## Unreleased

- Combo bonus label comes from `GameStrings.combo`; trail and hit tuning moved to named constants.
- `SliceDifficulty` is now a class with `easy` / `normal` / `hard` presets and `copyWith`. Emits `slice` and `bomb` sound cues.
- Fix: particle effects no longer draw from the injected `Random`, so a seeded game throws the same waves however the player slices.
- Internal cleanup: core countdown/end-cause/loading helpers, shared `Ballistic` motion, `SlicedHalfComponent.split`, named launch constants. Images load in parallel.
- `SliceStatKeys`: const keys for `GameResult.stats`.

## 0.1.0

- Initial release.
