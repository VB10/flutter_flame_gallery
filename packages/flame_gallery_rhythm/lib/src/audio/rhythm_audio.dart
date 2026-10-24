/// Music backend for Note Rush. The library ships no audio dependency; host
/// apps implement this with the player they already use (audioplayers,
/// just_audio, flame_audio...).
///
/// Calls are fire-and-forget from the game loop; failures are swallowed so a
/// broken player never stops the round.
abstract interface class RhythmAudio {
  /// Starts the song from the beginning.
  Future<void> start();

  Future<void> pause();

  Future<void> resume();

  Future<void> stop();

  /// Current playback position, or `null` if unknown. When non-null the game
  /// clock follows it, keeping notes in sync with the music.
  Duration? get position;
}
