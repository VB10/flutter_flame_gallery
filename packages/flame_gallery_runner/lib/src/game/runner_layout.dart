import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame_gallery_runner/src/logic/obstacle_row_planner.dart';

/// Screen geometry of the track, derived from the game size.
final class RunnerLayout {
  RunnerLayout(Vector2 size)
    : width = size.x,
      height = size.y,
      laneWidth = math.min(
        size.x / _widthInLanes,
        size.y * _maxLaneHeightFactor,
      );

  /// Screen width expressed in lanes; leaves a margin beside the path.
  static const _widthInLanes = 3.4;
  static const _maxLaneHeightFactor = 0.16;
  static const _playerYFactor = 0.78;
  static const _playerSizeFactor = 0.8;
  static const _blockSizeFactor = 0.85;
  static const _barrierWidthFactor = 0.95;
  static const _barrierHeightFactor = 0.48;
  static const _coinSizeFactor = 0.4;
  static const _coinSpacingFactor = 0.7;

  final double width;
  final double height;
  final double laneWidth;

  static const int laneCount = ObstacleRowPlanner.laneCount;

  double get pathWidth => laneWidth * laneCount;
  double get pathLeft => (width - pathWidth) / 2;
  double get playerY => height * _playerYFactor;
  double get playerSize => laneWidth * _playerSizeFactor;
  Vector2 get blockSize => Vector2.all(laneWidth * _blockSizeFactor);
  Vector2 get barrierSize => Vector2(
    laneWidth * _barrierWidthFactor,
    laneWidth * _barrierHeightFactor,
  );
  Vector2 get coinSize => Vector2.all(laneWidth * _coinSizeFactor);
  double get coinSpacing => laneWidth * _coinSpacingFactor;

  double laneCenterX(int lane) => pathLeft + laneWidth * (lane + 0.5);

  int laneAt(double x) =>
      ((x - pathLeft) / laneWidth).floor().clamp(0, laneCount - 1);
}
