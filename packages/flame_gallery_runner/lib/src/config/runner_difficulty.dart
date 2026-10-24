/// Scroll pacing. Speeds and spacing are in screen heights so the game plays
/// the same on every device.
enum RunnerDifficulty {
  easy(startSpeed: 0.45, maxSpeed: 0.9, rampSeconds: 60, rowSpacing: 0.55),
  normal(startSpeed: 0.55, maxSpeed: 1.15, rampSeconds: 50, rowSpacing: 0.48),
  hard(startSpeed: 0.7, maxSpeed: 1.4, rampSeconds: 40, rowSpacing: 0.42);

  RunnerDifficulty({
    required this.startSpeed,
    required this.maxSpeed,
    required this.rampSeconds,
    required this.rowSpacing,
  });

  /// Screen heights per second at the start of a round.
  final double startSpeed;

  /// Screen heights per second once [rampSeconds] have passed.
  final double maxSpeed;
  final double rampSeconds;

  /// Distance between obstacle rows, in screen heights.
  final double rowSpacing;
}
