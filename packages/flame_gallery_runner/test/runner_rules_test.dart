import 'package:flame_gallery_runner/flame_gallery_runner.dart';
import 'package:flame_gallery_runner/src/logic/runner_rules.dart';
import 'package:flame_gallery_runner/src/logic/runner_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('collides', () {
    const table = {
      (ObstacleKind.block, PlayerPose.running): true,
      (ObstacleKind.block, PlayerPose.jumping): true,
      (ObstacleKind.block, PlayerPose.sliding): true,
      (ObstacleKind.lowBarrier, PlayerPose.running): true,
      (ObstacleKind.lowBarrier, PlayerPose.jumping): false,
      (ObstacleKind.lowBarrier, PlayerPose.sliding): true,
      (ObstacleKind.highBarrier, PlayerPose.running): true,
      (ObstacleKind.highBarrier, PlayerPose.jumping): true,
      (ObstacleKind.highBarrier, PlayerPose.sliding): false,
    };
    for (final MapEntry(key: (kind, pose), value: expected) in table.entries) {
      test('${kind.name} vs ${pose.name} → $expected', () {
        expect(RunnerRules.collides(kind, pose), expected);
      });
    }
  });

  test('score is metres plus coins times coin value', () {
    expect(RunnerRules.score(meters: 120, coins: 7, coinValue: 5), 155);
  });

  test('speed ramps from start to max and then holds', () {
    const d = RunnerDifficulty.normal;
    expect(RunnerRules.speedAt(0, d), d.startSpeed);
    expect(
      RunnerRules.speedAt(d.rampSeconds / 2, d),
      closeTo((d.startSpeed + d.maxSpeed) / 2, 1e-9),
    );
    expect(RunnerRules.speedAt(d.rampSeconds * 3, d), d.maxSpeed);
  });

  group('SwipeDirection.fromDelta', () {
    test('horizontal', () {
      expect(SwipeDirection.fromDelta(-30, 5), SwipeDirection.left);
      expect(SwipeDirection.fromDelta(30, -5), SwipeDirection.right);
    });

    test('vertical (screen y grows downward)', () {
      expect(SwipeDirection.fromDelta(4, -30), SwipeDirection.up);
      expect(SwipeDirection.fromDelta(-4, 30), SwipeDirection.down);
    });
  });
}
