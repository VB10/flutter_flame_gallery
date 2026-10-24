import 'package:flame_gallery_slice/src/logic/slice_rules.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('slices return item points and are counted', () {
    final rules = SliceRules(maxLives: 3);
    expect(rules.registerSlice(2), 2);
    expect(rules.sliced, 1);
  });

  test('combo bonus only from the threshold on', () {
    final rules = SliceRules(maxLives: 3)
      ..registerSlice(1)
      ..registerSlice(1);
    expect(rules.endStroke(), 0);

    for (var i = 0; i < 4; i++) {
      rules.registerSlice(1);
    }
    expect(rules.endStroke(), 4);
    expect(rules.maxCombo, 4);
  });

  test('last miss reports out of lives', () {
    final rules = SliceRules(maxLives: 2);
    expect(rules.registerMiss(), isFalse);
    expect(rules.registerMiss(), isTrue);
    expect(rules.lives, 0);
  });

  test('unlimited lives never run out', () {
    final rules = SliceRules(maxLives: null);
    expect(rules.registerMiss(), isFalse);
    expect(rules.lives, isNull);
  });

  test('reset restores lives and counters', () {
    final rules = SliceRules(maxLives: 3)
      ..registerMiss()
      ..registerSlice(1)
      ..reset();
    expect(rules.lives, 3);
    expect(rules.sliced, 0);
  });
}
