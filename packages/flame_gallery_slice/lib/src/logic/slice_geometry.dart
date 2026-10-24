import 'package:flame/components.dart';

/// Whether the swipe segment [start]→[end] passes through the circle.
bool segmentHitsCircle(
  Vector2 start,
  Vector2 end,
  Vector2 center,
  double radius,
) {
  final segment = end - start;
  final lengthSquared = segment.length2;
  final t = lengthSquared == 0
      ? 0.0
      : ((center - start).dot(segment) / lengthSquared).clamp(0.0, 1.0);
  final closest = start + segment * t;
  return closest.distanceToSquared(center) <= radius * radius;
}
