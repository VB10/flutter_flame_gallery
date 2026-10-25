import 'package:flutter/foundation.dart';

/// How long a note is visible before it reaches the hit line. Use a preset
/// ([easy], [normal], [hard]) or `RhythmDifficulty(approachSeconds: 1.1)`.
@immutable
final class RhythmDifficulty {
  const RhythmDifficulty({required this.approachSeconds})
    : assert(approachSeconds > 0, 'approachSeconds must be positive');

  static const easy = RhythmDifficulty(approachSeconds: 2.2);
  static const normal = RhythmDifficulty(approachSeconds: 1.7);
  static const hard = RhythmDifficulty(approachSeconds: 1.3);

  final double approachSeconds;

  @override
  bool operator ==(Object other) =>
      other is RhythmDifficulty && other.approachSeconds == approachSeconds;

  @override
  int get hashCode => approachSeconds.hashCode;
}
