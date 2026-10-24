enum ObstacleKind { block, lowBarrier, highBarrier }

enum PlayerPose { running, jumping, sliding }

enum SwipeDirection {
  left,
  right,
  up,
  down;

  /// Dominant axis wins; ties count as horizontal.
  static SwipeDirection fromDelta(double dx, double dy) {
    if (dx.abs() >= dy.abs()) return dx < 0 ? left : right;
    return dy < 0 ? up : down;
  }
}
