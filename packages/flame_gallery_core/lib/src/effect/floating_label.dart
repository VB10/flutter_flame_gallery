import 'package:flame/components.dart';
import 'package:flame/effects.dart';

/// Short text ("×3", "Perfect") that rises and removes itself.
///
/// Pass a [TextPaint] created once by the caller: building one per label means
/// a new text style and layout for every hit.
final class FloatingLabel extends TextComponent {
  FloatingLabel({
    required super.text,
    required Vector2 position,
    required TextPaint paint,
    this.rise = 60,
    this.duration = 0.6,
  }) : super(
         position: position.clone(),
         anchor: Anchor.center,
         textRenderer: paint,
       );

  final double rise;
  final double duration;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await addAll([
      MoveByEffect(Vector2(0, -rise), EffectController(duration: duration)),
      RemoveEffect(delay: duration),
    ]);
  }
}
