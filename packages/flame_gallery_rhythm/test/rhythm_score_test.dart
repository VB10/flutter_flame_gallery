import 'package:flame_gallery_rhythm/src/logic/rhythm_judge.dart';
import 'package:flame_gallery_rhythm/src/logic/rhythm_score.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts at full accuracy with no combo', () {
    final score = RhythmScore();
    expect(score.accuracy, RhythmScore.fullAccuracy);
    expect(score.combo, 0);
    expect(score.multiplier, 1);
  });

  test('the 10th combo hit earns ×2, capped at ×4', () {
    final score = RhythmScore();
    final points = [
      for (var i = 0; i < 45; i++) score.register(Judgement.good),
    ];
    expect(points[8], 100);
    expect(points[9], 200);
    expect(points[19], 300);
    expect(points[29], 400);
    expect(points[44], 400);
    expect(score.maxCombo, 45);
  });

  test('a miss scores nothing and resets the combo', () {
    final score = RhythmScore()
      ..register(Judgement.perfect)
      ..register(Judgement.perfect);
    expect(score.register(Judgement.miss), 0);
    expect(score.combo, 0);
    expect(score.maxCombo, 2);
  });

  test('accuracy weighs hits against all perfects', () {
    final score = RhythmScore()
      ..register(Judgement.perfect)
      ..register(Judgement.good)
      ..register(Judgement.miss)
      ..register(Judgement.great);
    // (300 + 100 + 0 + 200) / (4 * 300) = 50%
    expect(score.accuracy, 50);
    expect(score.judged, 4);
  });

  test('reset clears counts and combo', () {
    final score = RhythmScore()
      ..register(Judgement.perfect)
      ..register(Judgement.miss)
      ..reset();
    expect(score.judged, 0);
    expect(score.maxCombo, 0);
  });
}
