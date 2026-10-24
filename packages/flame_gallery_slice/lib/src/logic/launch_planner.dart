import 'dart:math' as math;

import 'package:flame/components.dart';

typedef Launch = ({Vector2 position, Vector2 velocity, double gravity});

/// Plans a throw from below the screen that peaks inside the play area and
/// drifts toward the middle.
final class LaunchPlanner {
  LaunchPlanner({math.Random? random}) : _random = random ?? math.Random();

  /// Apex height range, as a fraction of the screen height from the top.
  static const minApex = 0.15;
  static const maxApex = 0.45;

  final math.Random _random;

  Launch plan({
    required Vector2 area,
    required double itemRadius,
    double speedFactor = 1,
  }) {
    final gravity = area.y * 1.2 * speedFactor * speedFactor;
    final startX = area.x * _between(0.15, 0.85);
    final startY = area.y + itemRadius;
    final apexY = area.y * _between(minApex, maxApex);
    final vy = -math.sqrt(2 * gravity * (startY - apexY));
    final timeToApex = -vy / gravity;
    final targetX = area.x * _between(0.3, 0.7);
    final vx = (targetX - startX) / (2 * timeToApex);
    return (
      position: Vector2(startX, startY),
      velocity: Vector2(vx, vy),
      gravity: gravity,
    );
  }

  double _between(double min, double max) =>
      min + _random.nextDouble() * (max - min);
}
