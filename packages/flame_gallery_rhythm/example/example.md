# flame_gallery_rhythm example

Note Rush ships no audio dependency. Implement `RhythmAudio` with the player
your app already uses; the game clock follows `position` so notes stay in sync.

```dart
import 'package:audioplayers/audioplayers.dart';
import 'package:flame_gallery_rhythm/flame_gallery_rhythm.dart';

final class AssetSongAudio implements RhythmAudio {
  AssetSongAudio(this.asset);

  final String asset;
  final AudioPlayer _player = AudioPlayer();
  Duration? _position;

  @override
  Future<void> start() async {
    _player.onPositionChanged.listen((p) => _position = p);
    await _player.play(AssetSource(asset));
  }

  @override
  Future<void> pause() => _player.pause();

  @override
  Future<void> resume() => _player.resume();

  @override
  Future<void> stop() async {
    _position = null;
    await _player.stop();
  }

  @override
  Duration? get position => _position;
}

final game = NoteRush(
  audio: AssetSongAudio('audio/my_song.mp3'),
  config: const RhythmConfig(song: RhythmSong.demo, missLimit: 10),
);
```

`RhythmSong.demo` is 120 BPM with a 2 s lead-in: beat `k` sounds at
`2.0 + k * 0.5` seconds. Author your own `RhythmSong` (bpm, leadIn, beats,
notes) to match any track, or use `RhythmSong.generated(...)`.
