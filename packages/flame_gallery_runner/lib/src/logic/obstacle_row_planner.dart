import 'dart:math' as math;

import 'package:flame_gallery_runner/src/logic/runner_types.dart';
import 'package:flutter/foundation.dart';

/// One row of the track: an optional obstacle per lane plus an optional lane
/// holding a line of coins.
@immutable
final class RunnerRow {
  const RunnerRow({required this.obstacles, this.coinLane});

  final List<ObstacleKind?> obstacles;
  final int? coinLane;

  int get blockCount =>
      obstacles.where((kind) => kind == ObstacleKind.block).length;

  /// At least one lane can be crossed by running, jumping or sliding.
  bool get isPassable => obstacles.any((kind) => kind != ObstacleKind.block);
}

/// Generates fair rows: never more than [maxBlocks] blocks, so one lane is
/// always passable.
final class ObstacleRowPlanner {
  ObstacleRowPlanner({math.Random? random}) : _random = random ?? math.Random();

  static const laneCount = 3;
  static const maxBlocks = 2;
  static const coinChance = 0.6;

  /// Cumulative odds for 1, 2 and 3 obstacles in a row.
  static const _oneObstacleOdds = 0.45;
  static const _twoObstaclesOdds = 0.85;

  final math.Random _random;

  RunnerRow plan() {
    final obstacles = List<ObstacleKind?>.filled(laneCount, null);
    final lanes = List<int>.generate(laneCount, (i) => i)..shuffle(_random);
    var blocks = 0;
    for (final lane in lanes.take(_obstacleCount())) {
      var kind =
          ObstacleKind.values[_random.nextInt(ObstacleKind.values.length)];
      if (kind == ObstacleKind.block && blocks == maxBlocks) {
        kind = _random.nextBool()
            ? ObstacleKind.lowBarrier
            : ObstacleKind.highBarrier;
      }
      if (kind == ObstacleKind.block) blocks++;
      obstacles[lane] = kind;
    }

    final freeLanes = [
      for (var lane = 0; lane < laneCount; lane++)
        if (obstacles[lane] == null) lane,
    ];
    final coinLane = freeLanes.isNotEmpty && _random.nextDouble() < coinChance
        ? freeLanes[_random.nextInt(freeLanes.length)]
        : null;
    return RunnerRow(obstacles: obstacles, coinLane: coinLane);
  }

  int _obstacleCount() {
    final roll = _random.nextDouble();
    if (roll < _oneObstacleOdds) return 1;
    if (roll < _twoObstaclesOdds) return 2;
    return laneCount;
  }
}
