import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame_gallery_slice/src/component/ballistic.dart';
import 'package:flame_gallery_slice/src/component/slice_item_component.dart';

/// One half of a sliced item, falling off screen.
final class SlicedHalfComponent extends SpriteComponent
    with Ballistic, HasGameReference {
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

  /// Speed each half gets away from the cut line.
  static const _push = 160.0;

  @override
  final Vector2 velocity;
  @override
  final double gravity;
  @override
  final double spin;

  /// Cuts [item]'s sprite into left and right halves along the swipe
  /// [direction]; they keep its motion and drift apart across the cut.
  static List<SlicedHalfComponent> split(
    SliceItemComponent item,
    Vector2 direction,
  ) {
    final image = item.sprite!.image;
    final sourceSize = Vector2(image.width / 2, image.height.toDouble());
    final cutAngle = math.atan2(direction.y, direction.x) + math.pi / 2;
    final push = Vector2(math.cos(cutAngle), math.sin(cutAngle))..scale(_push);
    final halfSize = Vector2(item.size.x / 2, item.size.y);

    SlicedHalfComponent half({required bool left}) {
      final side = left ? -1.0 : 1.0;
      return SlicedHalfComponent(
        sprite: Sprite(
          image,
          srcPosition: left ? Vector2.zero() : Vector2(sourceSize.x, 0),
          srcSize: sourceSize,
        ),
        position: item.position.clone(),
        size: halfSize,
        anchor: left ? Anchor.centerRight : Anchor.centerLeft,
        angle: cutAngle,
        velocity: item.velocity.clone()..addScaled(push, side),
        gravity: item.gravity,
        spin: item.spin * side,
      );
    }

    return [half(left: true), half(left: false)];
  }

  @override
  void update(double dt) {
    super.update(dt);
    fly(dt);
    if (position.y - size.y > game.size.y) removeFromParent();
  }
}
