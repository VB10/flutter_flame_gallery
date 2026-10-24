import 'dart:math' as math;

import 'package:flame_gallery_rhythm/src/logic/rhythm_judge.dart';

/// Combo, multiplier, counts and accuracy. Pure, no Flame.
final class RhythmScore {
  /// Every this many combo hits raises the multiplier by one.
  static const comboStep = 10;
  static const maxMultiplier = 4;
  static const fullAccuracy = 100;

  final Map<Judgement, int> _counts = {
    for (final judgement in Judgement.values) judgement: 0,
  };
  int _combo = 0;
  int _maxCombo = 0;

  int get combo => _combo;
  int get maxCombo => _maxCombo;
  int countOf(Judgement judgement) => _counts[judgement]!;
  int get judged => _counts.values.fold(0, (sum, count) => sum + count);

  /// Multiplier applied to the current hit; the hit that reaches combo 10
  /// already earns ×2.
  int get multiplier => math.min(maxMultiplier, 1 + _combo ~/ comboStep);

  /// Weighted hits over the maximum possible, 0–100. 100 before any note.
  int get accuracy {
    final total = judged;
    if (total == 0) return fullAccuracy;
    final earned = _counts.entries.fold(
      0,
      (sum, entry) => sum + entry.key.points * entry.value,
    );
    return (earned * fullAccuracy / (total * Judgement.perfect.points)).round();
  }

  void reset() {
    _counts.updateAll((_, _) => 0);
    _combo = 0;
    _maxCombo = 0;
  }

  /// Records one judgement and returns the points it earned.
  int register(Judgement judgement) {
    _counts[judgement] = _counts[judgement]! + 1;
    if (!judgement.isHit) {
      _combo = 0;
      return 0;
    }
    _combo++;
    _maxCombo = math.max(_maxCombo, _combo);
    return judgement.points * multiplier;
  }
}
