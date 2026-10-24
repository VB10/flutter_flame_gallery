import 'dart:async';

import 'package:flame_audio/flame_audio.dart';
import 'package:flame_gallery/flame_gallery.dart';

/// Plays a bundled song for Note Rush with audioplayers (via flame_audio).
///
/// audioplayers reports the position only every ~200 ms, so [position] adds
/// the time elapsed since the last report; notes then move smoothly while
/// staying locked to the music.
final class AssetRhythmAudio implements RhythmAudio {
  AssetRhythmAudio(this.asset);

  /// Path under `assets/`, e.g. `audio/note_rush_demo.mp3`.
  final String asset;

  AudioPlayer? _player;
  StreamSubscription<Duration>? _positionSubscription;
  final Stopwatch _sinceReport = Stopwatch();
  Duration? _reported;

  @override
  Future<void> start() async {
    await stop();
    final player = _player ??= AudioPlayer();
    _positionSubscription = player.onPositionChanged.listen(_onPosition);
    await player.play(AssetSource(asset));
  }

  @override
  Future<void> pause() async {
    _sinceReport.stop();
    await _player?.pause();
  }

  @override
  Future<void> resume() async {
    await _player?.resume();
    _sinceReport.start();
  }

  @override
  Future<void> stop() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _reported = null;
    _sinceReport
      ..stop()
      ..reset();
    await _player?.stop();
  }

  @override
  Duration? get position {
    final reported = _reported;
    return reported == null ? null : reported + _sinceReport.elapsed;
  }

  void _onPosition(Duration position) {
    _reported = position;
    _sinceReport
      ..reset()
      ..start();
  }
}
