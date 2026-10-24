import 'package:flame_gallery_rhythm/src/logic/rhythm_judge.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const cases = <(double, Judgement?)>[
    (0, Judgement.perfect),
    (0.06, Judgement.perfect),
    (-0.06, Judgement.perfect),
    (0.0601, Judgement.great),
    (0.12, Judgement.great),
    (-0.12, Judgement.great),
    (0.1201, Judgement.good),
    (0.18, Judgement.good),
    (-0.18, Judgement.good),
    (0.1801, null),
    (-0.5, null),
  ];

  for (final (delta, expected) in cases) {
    test('delta $delta → $expected', () {
      expect(RhythmJudge.judge(delta), expected);
    });
  }

  test('a tap computed from float sums still hits the window edge', () {
    expect(RhythmJudge.judge(1.06 - 1.0), Judgement.perfect);
  });
}
