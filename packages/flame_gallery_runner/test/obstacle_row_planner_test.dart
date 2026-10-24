import 'dart:math' as math;

import 'package:flame_gallery_runner/src/logic/obstacle_row_planner.dart';
import 'package:flame_gallery_runner/src/logic/runner_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'every row is passable, has ≤ 2 blocks and coins only in free lanes',
    () {
      for (var seed = 0; seed < 50; seed++) {
        final planner = ObstacleRowPlanner(random: math.Random(seed));
        for (var i = 0; i < 200; i++) {
          final row = planner.plan();
          expect(row.obstacles, hasLength(ObstacleRowPlanner.laneCount));
          expect(row.obstacles.whereType<ObstacleKind>(), isNotEmpty);
          expect(
            row.blockCount,
            lessThanOrEqualTo(ObstacleRowPlanner.maxBlocks),
          );
          expect(row.isPassable, isTrue);
          final coinLane = row.coinLane;
          if (coinLane != null) expect(row.obstacles[coinLane], isNull);
        }
      }
    },
  );

  test('produces every obstacle kind and some coin lines', () {
    final planner = ObstacleRowPlanner(random: math.Random(3));
    final rows = List.generate(300, (_) => planner.plan());
    final kinds = rows.expand((r) => r.obstacles).whereType<ObstacleKind>();
    expect(kinds.toSet(), ObstacleKind.values.toSet());
    expect(rows.where((r) => r.coinLane != null), isNotEmpty);
  });
}
