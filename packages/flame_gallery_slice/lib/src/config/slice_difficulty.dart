/// Spawn pacing. Each value ramps from its initial to its peak pacing over
/// [rampSeconds] of play.
enum SliceDifficulty {
  easy(
    initialInterval: 1.5,
    minInterval: 0.8,
    maxWaveSize: 3,
    speedFactor: 0.9,
  ),
  normal(
    initialInterval: 1.2,
    minInterval: 0.55,
    maxWaveSize: 4,
    speedFactor: 1,
  ),
  hard(
    initialInterval: 0.95,
    minInterval: 0.4,
    maxWaveSize: 5,
    speedFactor: 1.15,
  );

  SliceDifficulty({
    required this.initialInterval,
    required this.minInterval,
    required this.maxWaveSize,
    required this.speedFactor,
  });

  final double initialInterval;
  final double minInterval;
  final int maxWaveSize;
  final double speedFactor;

  double get rampSeconds => 45;
}
