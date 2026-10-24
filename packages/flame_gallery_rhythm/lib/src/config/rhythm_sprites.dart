import 'package:flame_gallery_core/flame_gallery_core.dart';

const _package = 'flame_gallery_rhythm';

/// Built-in note sprites, one colour and shape per lane.
abstract final class RhythmSprites {
  static const circle = GameAsset(
    'assets/images/note_circle.png',
    package: _package,
  );
  static const diamond = GameAsset(
    'assets/images/note_diamond.png',
    package: _package,
  );
  static const hexagon = GameAsset(
    'assets/images/note_hexagon.png',
    package: _package,
  );
  static const square = GameAsset(
    'assets/images/note_square.png',
    package: _package,
  );

  /// Lane order; lanes beyond the list reuse it cyclically.
  static const List<GameAsset> notes = [circle, diamond, hexagon, square];
}
