# flame_gallery_rhythm

Note Rush for [Flame Gallery](https://pub.dev/packages/flame_gallery): notes fall down four lanes; tap a lane when its note reaches the line. Perfect / Great / Good timing, combos up to ×4, accuracy in the result.

<img src="https://raw.githubusercontent.com/VB10/flame_gallery/main/packages/flame_gallery/screenshots/note_rush.png" width="240" alt="Note Rush">

Most apps should depend on [`flame_gallery`](https://pub.dev/packages/flame_gallery) and call
`FlameGallery.show(context, game: NoteRush(audio: myAudio))`.

## Music

The package ships **no audio dependency**. Implement `RhythmAudio` (`start`, `pause`, `resume`, `stop`, `position`) with the player your app already uses (audioplayers, just_audio, flame_audio...). When `position` is known the game clock follows it, so notes stay locked to the music. Without audio the game runs on its own clock. See the [example](example/example.md).

## Configure

```dart
NoteRush(
  audio: myAudio,
  config: const RhythmConfig(
    song: RhythmSong.demo,             // or your own RhythmSong(bpm:, leadIn:, beats:, notes:)
    difficulty: RhythmDifficulty.normal, // note approach time 2.2 / 1.7 / 1.3 s
    missLimit: 10,                     // null → misses never end the round
  ),
)
```

Timing windows: Perfect ≤ 60 ms (300), Great ≤ 120 ms (200), Good ≤ 180 ms (100); a note not hit within 180 ms is a miss and resets the combo.

## Result stats

`perfect`, `great`, `good`, `miss`, `maxCombo`, `accuracy` (%), `endedBy` (`songEnd`, `tooManyMisses`, `quit`).

## License

MIT
