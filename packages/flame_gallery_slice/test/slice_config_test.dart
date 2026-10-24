import 'package:flame_gallery_slice/flame_gallery_slice.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('copyWith clears nullable fields and keeps omitted ones', () {
    const config = SliceConfig(lives: 3);

    final noBombs = config.copyWith(bomb: () => null);
    final endless = config.copyWith(timeLimit: () => null);

    expect(noBombs.bomb, isNull);
    expect(noBombs.lives, 3);
    expect(noBombs.timeLimit, config.timeLimit);
    expect(endless.timeLimit, isNull);
    expect(endless.bomb, SliceItem.bomb);
  });
}
