import 'dart:math' as math;

import 'package:flame/components.dart';

/// Screen geometry for a given game size and lane count.
final class RhythmLayout {
  RhythmLayout({required this.size, required this.lanes});

  /// Hit line position as a share of the screen height.
  static const hitLineFraction = 0.85;

  /// Note size relative to the lane width.
  static const _noteFactor = 0.72;
  static const _maxNoteFraction = 0.12;

  final Vector2 size;
  final int lanes;

  double get laneWidth => size.x / lanes;
  double get hitY => size.y * hitLineFraction;
  double get noteSize =>
      math.min(laneWidth * _noteFactor, size.y * _maxNoteFraction);

  /// Notes appear just above the top edge.
  double get spawnY => -noteSize;

  double laneCenterX(int lane) => laneWidth * (lane + 0.5);

  int? laneAt(double x) {
    if (x < 0 || x >= size.x) return null;
    return (x / laneWidth).floor();
  }

  /// Vertical position of a note [timeToHit] seconds before it reaches the
  /// hit line, given how long notes take to fall.
  double noteY({required double timeToHit, required double approachSeconds}) =>
      hitY - timeToHit / approachSeconds * (hitY - spawnY);
}
