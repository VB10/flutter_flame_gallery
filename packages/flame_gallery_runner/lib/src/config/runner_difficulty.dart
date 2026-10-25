import 'package:flutter/foundation.dart';

/// Scroll pacing. Speeds and spacing are in screen heights so the game plays
/// the same on every device. Use a preset ([easy], [normal], [hard]) or pass
/// your own numbers: `RunnerDifficulty.normal.copyWith(maxSpeed: 1.6)`.
@immutable
final class RunnerDifficulty {
  const RunnerDifficulty({
    required this.startSpeed,
    required this.maxSpeed,
    required this.rampSeconds,
    required this.rowSpacing,
  }) : assert(startSpeed > 0, 'startSpeed must be positive'),
       assert(maxSpeed >= startSpeed, 'maxSpeed must reach startSpeed'),
       assert(rampSeconds > 0, 'rampSeconds must be positive'),
       assert(rowSpacing > 0, 'rowSpacing must be positive');

  static const easy = RunnerDifficulty(
    startSpeed: 0.45,
    maxSpeed: 0.9,
    rampSeconds: 60,
    rowSpacing: 0.55,
  );
  static const normal = RunnerDifficulty(
    startSpeed: 0.55,
    maxSpeed: 1.15,
    rampSeconds: 50,
    rowSpacing: 0.48,
  );
  static const hard = RunnerDifficulty(
    startSpeed: 0.7,
    maxSpeed: 1.4,
    rampSeconds: 40,
    rowSpacing: 0.42,
  );

  /// Screen heights per second at the start of a round.
  final double startSpeed;

  /// Screen heights per second once [rampSeconds] have passed.
  final double maxSpeed;
  final double rampSeconds;

  /// Distance between obstacle rows, in screen heights.
  final double rowSpacing;

  RunnerDifficulty copyWith({
    double? startSpeed,
    double? maxSpeed,
    double? rampSeconds,
    double? rowSpacing,
  }) => RunnerDifficulty(
    startSpeed: startSpeed ?? this.startSpeed,
    maxSpeed: maxSpeed ?? this.maxSpeed,
    rampSeconds: rampSeconds ?? this.rampSeconds,
    rowSpacing: rowSpacing ?? this.rowSpacing,
  );

  @override
  bool operator ==(Object other) =>
      other is RunnerDifficulty &&
      other.startSpeed == startSpeed &&
      other.maxSpeed == maxSpeed &&
      other.rampSeconds == rampSeconds &&
      other.rowSpacing == rowSpacing;

  @override
  int get hashCode =>
      Object.hash(startSpeed, maxSpeed, rampSeconds, rowSpacing);
}
