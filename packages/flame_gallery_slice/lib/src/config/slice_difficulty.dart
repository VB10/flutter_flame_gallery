import 'package:flutter/foundation.dart';

/// Spawn pacing. Ramps from its initial to its peak pacing over [rampSeconds]
/// of play. Use a preset ([easy], [normal], [hard]) or pass your own numbers:
/// `SliceDifficulty.normal.copyWith(maxWaveSize: 6)`.
@immutable
final class SliceDifficulty {
  const SliceDifficulty({
    required this.initialInterval,
    required this.minInterval,
    required this.maxWaveSize,
    this.speedFactor = 1,
    this.rampSeconds = 45,
  }) : assert(initialInterval > 0, 'initialInterval must be positive'),
       assert(minInterval > 0, 'minInterval must be positive'),
       assert(maxWaveSize >= 1, 'maxWaveSize must be at least 1'),
       assert(speedFactor > 0, 'speedFactor must be positive'),
       assert(rampSeconds > 0, 'rampSeconds must be positive');

  static const easy = SliceDifficulty(
    initialInterval: 1.5,
    minInterval: 0.8,
    maxWaveSize: 3,
    speedFactor: 0.9,
  );
  static const normal = SliceDifficulty(
    initialInterval: 1.2,
    minInterval: 0.55,
    maxWaveSize: 4,
  );
  static const hard = SliceDifficulty(
    initialInterval: 0.95,
    minInterval: 0.4,
    maxWaveSize: 5,
    speedFactor: 1.15,
  );

  /// Seconds between waves at the start of a round.
  final double initialInterval;

  /// Seconds between waves once [rampSeconds] have passed.
  final double minInterval;
  final int maxWaveSize;

  /// Multiplies launch speed.
  final double speedFactor;
  final double rampSeconds;

  SliceDifficulty copyWith({
    double? initialInterval,
    double? minInterval,
    int? maxWaveSize,
    double? speedFactor,
    double? rampSeconds,
  }) => SliceDifficulty(
    initialInterval: initialInterval ?? this.initialInterval,
    minInterval: minInterval ?? this.minInterval,
    maxWaveSize: maxWaveSize ?? this.maxWaveSize,
    speedFactor: speedFactor ?? this.speedFactor,
    rampSeconds: rampSeconds ?? this.rampSeconds,
  );

  @override
  bool operator ==(Object other) =>
      other is SliceDifficulty &&
      other.initialInterval == initialInterval &&
      other.minInterval == minInterval &&
      other.maxWaveSize == maxWaveSize &&
      other.speedFactor == speedFactor &&
      other.rampSeconds == rampSeconds;

  @override
  int get hashCode => Object.hash(
    initialInterval,
    minInterval,
    maxWaveSize,
    speedFactor,
    rampSeconds,
  );
}
