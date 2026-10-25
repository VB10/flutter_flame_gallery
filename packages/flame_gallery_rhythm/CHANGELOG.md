## Unreleased

- Combo and accuracy HUD texts come from `GameStrings.combo` / `accuracy`.
- `RhythmDifficulty` is now a class with presets. Emits `noteHit` / `noteMiss` sound cues.
- Internal cleanup: song timing in `SongClock`, music control in `RhythmAudioSync`, open notes tracked by index instead of scanning children; core end-cause/loading helpers. Images load in parallel.
- `RhythmStatKeys`: const keys for `GameResult.stats`.

## 0.1.0

- Initial release.
