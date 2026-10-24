import 'package:flame/components.dart';
import 'package:flame_gallery_slice/src/config/slice_item.dart';
import 'package:flame_gallery_slice/src/game/slice_game.dart';

/// A thrown fruit or bomb. A `null` [item] means it is a bomb.
final class SliceItemComponent extends SpriteComponent
    with HasGameReference<SliceGame> {
  SliceItemComponent({
    required this.item,
    required Sprite sprite,
    required Vector2 position,
    required this.velocity,
    required this.gravity,
    required double diameter,
    required this.spin,
  }) : super(
         sprite: sprite,
         position: position,
         size: Vector2.all(diameter),
         anchor: Anchor.center,
       );

  final SliceItem? item;
  final Vector2 velocity;
  final double gravity;
  final double spin;
  bool isSliced = false;

  bool get isBomb => item == null;

  /// Hit radius, slightly smaller than the sprite to forgive transparent edges.
  double get hitRadius => size.x * 0.42;

  @override
  void update(double dt) {
    super.update(dt);
    velocity.y += gravity * dt;
    position.addScaled(velocity, dt);
    angle += spin * dt;
    final fellOut = velocity.y > 0 && position.y - size.y / 2 > game.size.y;
    if (!fellOut) return;
    removeFromParent();
    if (!isBomb && !isSliced) game.onItemMissed();
  }
}
