import 'package:flutter/foundation.dart';

/// Moments a game can make noise for. Games emit the cues that apply to them.
enum GameSoundCue {
  /// Any game.
  start,
  scoreUp,
  penalty,
  gameOver,

  /// Fruit Slice.
  slice,
  bomb,

  /// Endless Runner.
  jump,
  coin,
  hit,

  /// Sweet Swap.
  swap,
  match,

  /// Note Rush.
  noteHit,
  noteMiss,
}

/// Sound effects sink. Library packages never play audio themselves; the host
/// maps cues to its own player (e.g. `flame_audio`).
abstract interface class GameSounds {
  void play(GameSoundCue cue);
}

/// Default: plays nothing.
final class SilentSounds implements GameSounds {
  const SilentSounds();

  @override
  void play(GameSoundCue cue) {}
}

/// Convenience for hosts: one callback for all cues.
@immutable
final class CallbackSounds implements GameSounds {
  const CallbackSounds(this.onCue);

  final ValueChanged<GameSoundCue> onCue;

  @override
  void play(GameSoundCue cue) => onCue(cue);
}
