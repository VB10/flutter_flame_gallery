import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/painting.dart';

/// Short burst of droplets, used for juice and the bomb blast.
ParticleSystemComponent burst({
  required Vector2 position,
  required Color color,
  required math.Random random,
  int count = 14,
  double speed = 260,
  double maxRadius = 6,
}) => ParticleSystemComponent(
  position: position.clone(),
  particle: Particle.generate(
    count: count,
    lifespan: 0.6,
    generator: (_) => AcceleratedParticle(
      acceleration: Vector2(0, speed * 2.4),
      speed: Vector2.random(random)
        ..sub(Vector2.all(0.5))
        ..scale(speed * 2),
      child: CircleParticle(
        radius: 2 + random.nextDouble() * (maxRadius - 2),
        paint: Paint()..color = color,
      ),
    ),
  ),
);

/// "×3" style label that floats up and disappears.
final class ComboText extends TextComponent {
  ComboText({
    required super.text,
    required Vector2 position,
    required Color color,
  }) : super(
         position: position.clone(),
         anchor: Anchor.center,
         textRenderer: TextPaint(
           style: TextStyle(
             color: color,
             fontSize: 34,
             fontWeight: FontWeight.w800,
           ),
         ),
       );

  static const _duration = 0.7;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await addAll([
      MoveByEffect(Vector2(0, -70), EffectController(duration: _duration)),
      RemoveEffect(delay: _duration),
    ]);
  }
}
