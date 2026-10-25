/// Note Rush `GameResult.stats` keys, next to `GameStatKeys.endedBy`.
abstract final class RhythmStatKeys {
  /// Hits per timing grade.
  static const perfect = 'perfect';
  static const great = 'great';
  static const good = 'good';

  /// Notes that passed the hit line untouched.
  static const miss = 'miss';

  /// Longest run of hits without a miss.
  static const maxCombo = 'maxCombo';

  /// Weighted hit accuracy, 0–100.
  static const accuracy = 'accuracy';
}
