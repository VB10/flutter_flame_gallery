import 'dart:async';

import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_rhythm/src/audio/rhythm_audio.dart';
import 'package:flutter/foundation.dart';

/// Plays an optional [RhythmAudio] along with the game [phase]: starts on a
/// new round, pauses and resumes with the game, stops when the round ends.
///
/// Calls are fire-and-forget; a failing player never breaks the game loop.
final class RhythmAudioSync {
  RhythmAudioSync({required this.audio, required this.phase})
    : _lastPhase = phase.value {
    phase.addListener(_onPhaseChanged);
  }

  final RhythmAudio? audio;
  final ValueListenable<GamePhase> phase;
  GamePhase _lastPhase;
  bool _started = false;

  /// Detaches from [phase] and stops the music if it is still playing.
  void dispose() {
    phase.removeListener(_onPhaseChanged);
    _stop();
  }

  void _onPhaseChanged() {
    final previous = _lastPhase;
    final next = phase.value;
    _lastPhase = next;
    switch ((previous, next)) {
      case (GamePhase.ready || GamePhase.over, GamePhase.playing):
        _started = true;
        _call((audio) => audio.start());
      case (GamePhase.playing, GamePhase.paused):
        _call((audio) => audio.pause());
      case (GamePhase.paused, GamePhase.playing):
        _call((audio) => audio.resume());
      case (_, GamePhase.over):
        _stop();
      case _:
        break;
    }
  }

  void _stop() {
    if (!_started) return;
    _started = false;
    _call((audio) => audio.stop());
  }

  void _call(Future<void> Function(RhythmAudio audio) call) {
    final audio = this.audio;
    if (audio == null) return;
    try {
      unawaited(call(audio).catchError((Object _) {}));
    } on Object catch (_) {
      // Synchronous throw from the player; ignored on purpose.
    }
  }
}
