import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/animation.dart';

/// One sweet on the board. Position is local to the board component.
final class PieceComponent extends SpriteComponent {
  PieceComponent({
    required this.piece,
    required super.sprite,
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.center);

  final int piece;

  void moveTo(Vector2 target, double duration) => add(
    MoveToEffect(
      target,
      EffectController(duration: duration, curve: Curves.easeOutCubic),
    ),
  );

  /// Jumps to [target], dropping any running move (e.g. after a resize).
  void snapTo(Vector2 target) {
    removeAll(children.whereType<MoveToEffect>());
    position = target;
  }

  void vanish(double duration) => addAll([
    ScaleEffect.to(
      Vector2.zero(),
      EffectController(duration: duration, curve: Curves.easeIn),
    ),
    RemoveEffect(delay: duration),
  ]);

  void popIn(double duration) {
    scale = Vector2.zero();
    add(
      ScaleEffect.to(
        Vector2.all(1),
        EffectController(duration: duration, curve: Curves.easeOutBack),
      ),
    );
  }
}
