import 'dart:math' as math;

/// Pure scoring rules, kept free of Flame so they are trivially testable.
final class SliceRules {
  SliceRules({required this.maxLives}) : _lives = maxLives;

  /// Slices in one stroke needed for a combo bonus.
  static const comboThreshold = 3;

  final int? maxLives;
  int? _lives;
  int _sliced = 0;
  int _maxCombo = 0;
  int _stroke = 0;

  int? get lives => _lives;
  int get sliced => _sliced;
  int get maxCombo => _maxCombo;

  void reset() {
    _lives = maxLives;
    _sliced = 0;
    _maxCombo = 0;
    _stroke = 0;
  }

  /// Returns the points earned by slicing an item worth [points].
  int registerSlice(int points) {
    _sliced++;
    _stroke++;
    return points;
  }

  /// Closes the current stroke. Returns the combo bonus (0 if none).
  int endStroke() {
    final count = _stroke;
    _stroke = 0;
    if (count < comboThreshold) return 0;
    _maxCombo = math.max(_maxCombo, count);
    return count;
  }

  /// Returns `true` when this miss used up the last life.
  bool registerMiss() {
    final lives = _lives;
    if (lives == null) return false;
    _lives = math.max(0, lives - 1);
    return _lives == 0;
  }
}
