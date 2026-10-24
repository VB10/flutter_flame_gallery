import 'package:flame/components.dart';

/// One half of a sliced item, falling off screen.
final class SlicedHalfComponent extends SpriteComponent with HasGameReference {
  SlicedHalfComponent({
    required Sprite sprite,
    required Vector2 position,
    required Vector2 size,
    required Anchor anchor,
    required double angle,
    required this.velocity,
    required this.gravity,
    required this.spin,
  }) : super(
         sprite: sprite,
         position: position,
         size: size,
         anchor: anchor,
         angle: angle,
       );

  final Vector2 velocity;
  final double gravity;
  final double spin;

  @override
  void update(double dt) {
    super.update(dt);
    velocity.y += gravity * dt;
    position.addScaled(velocity, dt);
    angle += spin * dt;
    if (position.y - size.y > game.size.y) removeFromParent();
  }
}
