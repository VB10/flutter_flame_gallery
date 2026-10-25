import 'package:flame/components.dart';

/// Full screen image behind a game's world, stretched to cover.
final class BackdropSprite extends SpriteComponent {
  BackdropSprite({required super.sprite, super.priority});

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }
}
