import 'dart:ui';

import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flutter/foundation.dart';

const _package = 'flame_gallery_match';

/// One kind of swappable piece: a sweet, a product icon, a brand badge...
@immutable
final class MatchPiece {
  const MatchPiece({required this.sprite, required this.color});

  final GameAsset sprite;

  /// Burst color when the piece is cleared.
  final Color color;

  static const red = MatchPiece(
    sprite: GameAsset('assets/images/sweet_red.png', package: _package),
    color: Color(0xFFE53950),
  );
  static const orange = MatchPiece(
    sprite: GameAsset('assets/images/sweet_orange.png', package: _package),
    color: Color(0xFFFF9F28),
  );
  static const green = MatchPiece(
    sprite: GameAsset('assets/images/sweet_green.png', package: _package),
    color: Color(0xFF4CC85A),
  );
  static const yellow = MatchPiece(
    sprite: GameAsset('assets/images/sweet_yellow.png', package: _package),
    color: Color(0xFFFFD83A),
  );
  static const pink = MatchPiece(
    sprite: GameAsset('assets/images/sweet_pink.png', package: _package),
    color: Color(0xFFF06CC8),
  );
  static const blue = MatchPiece(
    sprite: GameAsset('assets/images/sweet_blue.png', package: _package),
    color: Color(0xFF4A8EFF),
  );

  static const List<MatchPiece> sweets = [
    red,
    orange,
    green,
    yellow,
    pink,
    blue,
  ];
}
