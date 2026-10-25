/// Seconds into the song as the player hears it.
///
/// Follows the music whenever the player reports a position (minus
/// [latency]), so it never drifts from it. Runs on frame time without music,
/// or when the player stops reporting. At the start it waits up to
/// [startTimeout] for the first report, so notes do not jump when the music
/// kicks in.
final class SongClock {
  SongClock({
    required this.hasAudio,
    this.latency = 0,
    this.startTimeout = defaultStartTimeout,
  });

  static const defaultStartTimeout = 1.0;

  final bool hasAudio;

  /// Seconds the player hears the music after its reported position.
  final double latency;
  final double startTimeout;
  double _time = 0;
  double _waited = 0;
  bool _heardMusic = false;

  double get time => _time;

  /// Song time for a fresh [audioPosition]; [time] when it is unknown.
  double at(double? audioPosition) =>
      audioPosition == null ? _time : audioPosition - latency;

  void reset() {
    _time = 0;
    _waited = 0;
    _heardMusic = false;
  }

  void advance(double dt, {double? audioPosition}) {
    if (audioPosition != null) {
      _heardMusic = true;
      _time = audioPosition - latency;
    } else if (hasAudio && !_heardMusic && _waited < startTimeout) {
      _waited += dt;
    } else {
      _time += dt;
    }
  }
}
