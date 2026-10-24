import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';

const _count = 12;
const _lifespan = 0.45;
const _speed = 180.0;
const _minRadius = 2.0;
const _maxRadius = 5.0;

/// Small burst of sparkles where a piece was cleared.
ParticleSystemComponent pieceBurst({
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
