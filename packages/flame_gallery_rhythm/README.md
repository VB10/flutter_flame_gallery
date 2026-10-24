# flame_gallery_rhythm

**Note Rush** for [Flame Gallery](https://pub.dev/packages/flame_gallery): notes fall down four lanes; tap a lane when its note reaches the line, in time with the music.

<img src="https://raw.githubusercontent.com/VB10/flutter_flame_gallery/main/packages/flame_gallery/screenshots/note_rush.png" width="240" alt="Note Rush gameplay">

Most apps depend on [`flame_gallery`](https://pub.dev/packages/flame_gallery) and call
`FlameGallery.show(context, game: NoteRush(audio: myAudio))`. Depend on this package directly if you only need this game.

## How to play

- Tap the lane as its note crosses the hit line. Timing decides the grade: **Perfect** within 60 ms (300 points), **Great** within 120 ms (200), **Good** within 180 ms (100). A note nobody taps is a **Miss** and resets the combo.
- Every 10 hits in a row raise the multiplier, up to ×4.
- The round ends with the song, or after `missLimit` misses when set. The result reports accuracy in percent.
- Lanes are independent: two-note chords take two fingers.

## How it works

- **Positions come from the clock, not from `dt`.** Every frame a note's position is computed from the song time and its own time, so nothing drifts no matter how long the song is.
- **The clock follows the music.** With a `RhythmAudio`, the song time is the player's reported position minus `RhythmConfig.audioLatency`; it is re-synced every frame. At start the clock waits (up to 1 s) for the first position report so notes do not jump when the music kicks in. Without audio the game runs on its own clock.
- **Judging is pure logic** (`src/logic/`): the nearest open note of the tapped lane is graded by its distance in time; taps far from any note are ignored.
- Songs are data: `RhythmSong(bpm:, leadIn:, beats:, notes:)`. `RhythmSong.demo` is 120 BPM with a 2 s lead-in (beat `k` sounds at `2.0 + k · 0.5` s); `RhythmSong.generated(...)` builds a deterministic chart for any tempo.

## Music

The package ships **no audio dependency**. Implement `RhythmAudio` (`start`, `pause`, `resume`, `stop`, `position`) with the player your app already uses (audioplayers, just_audio, flame_audio...). See the [example](example/example.md); the demo app's version smooths the player's ~200 ms position updates with a stopwatch.

## Configure

```dart
NoteRush(
  audio: myAudio,
  labels: RhythmLabels.tr,                     // Mükemmel / Harika / İyi / Kaçtı
  config: const RhythmConfig(
    song: RhythmSong.demo,                     // or your own RhythmSong
    difficulty: RhythmDifficulty.normal,       // note approach time 2.2 / 1.7 / 1.3 s
    missLimit: 10,                             // null → play the whole song
    audioLatency: Duration(milliseconds: 150), // e.g. Bluetooth headphones
  ),
)
```

Configs are immutable; nullable fields are cleared through `copyWith` with a getter: `config.copyWith(missLimit: () => null)`.

## Make it yours

```dart
NoteRush(
  theme: GameTheme(
    colorScheme: ColorScheme.fromSeed(seedColor: brandColor, brightness: Brightness.dark),
    logo: const AssetImage('assets/logo.png'),
  ),
  strings: NoteRush.stringsTr.copyWith(title: 'Summer Campaign'),
)
```

Without a `colorScheme` the game follows your app theme. Texts ship in English (`NoteRush.stringsEn`, default) and Turkish (`NoteRush.stringsTr`).

## Result stats

`perfect`, `great`, `good`, `miss`, `maxCombo`, `accuracy` (%), `endedBy` (`songEnd`, `tooManyMisses`, `quit`).

## UI test ids

Menus and HUD values carry `Semantics(identifier:)` ids for Maestro, Patrol or integration tests: `GalleryKeys` from `flame_gallery_core` (`gallery_start_button`, `gallery_pause_button`, `gallery_final_score`, `gallery_hud_score`, ...), plus `RhythmKeys.hudCombo` and `RhythmKeys.hudAccuracy`.

## License

MIT
