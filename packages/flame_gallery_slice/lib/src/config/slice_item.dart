import 'dart:ui';

import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flutter/foundation.dart';

const _package = 'flame_gallery_slice';

/// One sliceable thing: a fruit, a product box, a brand mascot...
@immutable
final class SliceItem {
  const SliceItem({
    required this.sprite,
    required this.juiceColor,
    this.points = 1,
    this.scale = 1,
  });

  final GameAsset sprite;
  final Color juiceColor;
  final int points;

  /// Size multiplier relative to the default item size.
  final double scale;

  static const apple = SliceItem(
    sprite: GameAsset('assets/images/apple.png', package: _package),
    juiceColor: Color(0xFFE53935),
  );
  static const orange = SliceItem(
    sprite: GameAsset('assets/images/orange.png', package: _package),
    juiceColor: Color(0xFFFB8C00),
  );
  static const lemon = SliceItem(
    sprite: GameAsset('assets/images/lemon.png', package: _package),
    juiceColor: Color(0xFFFDD835),
  );
  static const plum = SliceItem(
    sprite: GameAsset('assets/images/plum.png', package: _package),
    juiceColor: Color(0xFF8E24AA),
  );
  static const watermelon = SliceItem(
    sprite: GameAsset('assets/images/watermelon.png', package: _package),
    juiceColor: Color(0xFFE53958),
    points: 2,
    scale: 1.25,
  );

  static const List<SliceItem> fruits = [
    apple,
    orange,
    lemon,
    plum,
    watermelon,
  ];

  static const bomb = GameAsset('assets/images/bomb.png', package: _package);
}
