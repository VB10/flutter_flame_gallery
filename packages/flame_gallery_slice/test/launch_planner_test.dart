import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame_gallery_slice/src/logic/launch_planner.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'every throw starts below the screen and peaks inside the apex band',
    () {
      final planner = LaunchPlanner(random: math.Random(7));
      final area = Vector2(400, 800);

      for (var i = 0; i < 200; i++) {
        final launch = planner.plan(
          area: area,
          itemRadius: 30,
          speedFactor: 1.15,
        );
        final v = launch.velocity;
        final apexY = launch.position.y - v.y * v.y / (2 * launch.gravity);

        expect(launch.position.y, greaterThan(area.y));
        expect(v.y, isNegative);
        expect(
          apexY,
          inInclusiveRange(
            area.y * LaunchPlanner.minApex - 0.001,
            area.y * LaunchPlanner.maxApex + 0.001,
          ),
        );
      }
    },
  );
}
