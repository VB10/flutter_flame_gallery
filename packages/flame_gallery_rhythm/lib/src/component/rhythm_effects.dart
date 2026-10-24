import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flame/particles.dart';
import 'package:flutter/painting.dart';

/// Sparkles where a note was hit.
abstract final class HitBurst {
  static const _count = 12;
  static const _lifespan = 0.35;
  static const _speed = 220.0;
  static const _minRadius = 2.0;
  static const _maxRadius = 4.5;

  static ParticleSystemComponent at({
    required Vector2 position,
    required Color color,
    required math.Random random,
  }) => ParticleSystemComponent(
    position: position.clone(),
    particle: Particle.generate(
      count: _count,
      lifespan: _lifespan,
      generator: (_) => AcceleratedParticle(
        speed: Vector2.random(random)
          ..sub(Vector2.all(0.5))
          ..scale(_speed * 2),
        child: CircleParticle(
          radius: _minRadius + random.nextDouble() * (_maxRadius - _minRadius),
          paint: Paint()..color = color,
        ),
      ),
    ),
  );
}

/// "Perfect" / "Miss" label that floats up from the hit line and vanishes.
final class JudgementText extends TextComponent {
  JudgementText({
    required super.text,
    required Vector2 position,
    required Color color,
  }) : super(
         position: position.clone(),
         anchor: Anchor.center,
         textRenderer: TextPaint(
           style: TextStyle(
             color: color,
             fontSize: _fontSize,
             fontWeight: FontWeight.w800,
           ),
         ),
       );

  static const _fontSize = 22.0;
  static const _rise = -48.0;
  static const _duration = 0.5;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    await addAll([
      MoveByEffect(Vector2(0, _rise), EffectController(duration: _duration)),
      RemoveEffect(delay: _duration),
    ]);
  }
}
