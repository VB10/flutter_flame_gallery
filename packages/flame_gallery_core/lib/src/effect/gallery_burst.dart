import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/particles.dart';

/// Radial burst of round particles: juice, sparkles, explosions.
///
/// One [Paint] is shared by every particle of a burst.
abstract final class GalleryBurst {
  static ParticleSystemComponent at({
    required Vector2 position,
    required Color color,
    required math.Random random,
    int count = 12,
    double lifespan = 0.45,
    double speed = 200,
    double minRadius = 2,
    double maxRadius = 5,
    double gravity = 0,
  }) {
    final paint = Paint()..color = color;
    return ParticleSystemComponent(
      position: position.clone(),
      particle: Particle.generate(
        count: count,
        lifespan: lifespan,
        generator: (_) => AcceleratedParticle(
          acceleration: Vector2(0, gravity),
          speed: Vector2.random(random)
            ..sub(Vector2.all(0.5))
            ..scale(speed * 2),
          child: CircleParticle(
            radius: minRadius + random.nextDouble() * (maxRadius - minRadius),
            paint: paint,
          ),
        ),
      ),
    );
  }
}
