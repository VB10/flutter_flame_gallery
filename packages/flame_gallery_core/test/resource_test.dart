import 'package:flame/cache.dart';
import 'package:flame/flame.dart';
import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

final class _Game extends GalleryFlameGame {
  _Game() : super(gameId: 'resource');

  @override
  void onRoundStart() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('removing a game frees its private image cache', () async {
    final game = _Game()..images = Images(prefix: '');
    game.images.add('sprite', await generateImage());

    game.onRemove();

    expect(game.images.containsKey('sprite'), isFalse);
  });

  test('the global Flame.images cache is left alone', () async {
    Flame.images.add('shared', await generateImage());
    _Game()
      ..images = Flame.images
      ..onRemove();

    expect(Flame.images.containsKey('shared'), isTrue);
    Flame.images.clear('shared');
  });

  test('GameTheme.copyWith keeps omitted fields and clears with null', () {
    const logo = AssetImage('logo.png');
    const theme = GameTheme(fontFamily: 'Inter', logo: logo);

    final kept = theme.copyWith(fontFamily: () => 'Mono');
    final cleared = theme.copyWith(logo: () => null);

    expect(kept.logo, logo);
    expect(kept.fontFamily, 'Mono');
    expect(cleared.logo, isNull);
    expect(cleared.fontFamily, 'Inter');
  });
}
