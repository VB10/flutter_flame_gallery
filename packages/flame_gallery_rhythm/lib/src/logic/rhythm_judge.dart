/// Timing grade of a tap, with its base points.
enum Judgement {
  perfect(points: 300),
  great(points: 200),
  good(points: 100),
  miss(points: 0);

  Judgement({required this.points});

  final int points;

  bool get isHit => this != miss;
}

/// Hit windows, in seconds either side of a note's time.
abstract final class RhythmJudge {
  static const perfectWindow = 0.06;
  static const greatWindow = 0.12;
  static const goodWindow = 0.18;

  /// Absorbs float noise so a tap exactly on a window edge still counts.
  static const _epsilon = 1e-9;

  /// Grade for a tap [delta] seconds away from the note, or `null` when the
  /// tap is outside every window (ignored, no penalty).
  static Judgement? judge(double delta) {
    final distance = delta.abs() - _epsilon;
    if (distance <= perfectWindow) return Judgement.perfect;
    if (distance <= greatWindow) return Judgement.great;
    if (distance <= goodWindow) return Judgement.good;
    return null;
  }
}
