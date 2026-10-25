import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('fill replaces the value placeholder', () {
    expect(GameStrings.fill('{value} m', 42), '42 m');
    expect(GameStrings.fill('×{value}', 3), '×3');
  });

  test('value templates have localized defaults and can be overridden', () {
    const en = GameStrings.en(title: 't', instructions: 'i');
    const tr = GameStrings.tr(title: 't', instructions: 'i');
    expect(en.accuracy, '{value}%');
    expect(tr.accuracy, '%{value}');

    final custom = en.copyWith(combo: 'COMBO {value}!', distance: '{value} km');
    expect(GameStrings.fill(custom.combo, 5), 'COMBO 5!');
    expect(GameStrings.fill(custom.distance, 2), '2 km');
    expect(custom.accuracy, en.accuracy);
  });
}
