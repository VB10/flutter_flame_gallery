import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GameAsset.key', () {
    test('host asset keeps its path', () {
      expect(const GameAsset('assets/a.png').key, 'assets/a.png');
    });

    test('package asset is prefixed', () {
      expect(
        const GameAsset('assets/a.png', package: 'game_x').key,
        'packages/game_x/assets/a.png',
      );
    });
  });
}
