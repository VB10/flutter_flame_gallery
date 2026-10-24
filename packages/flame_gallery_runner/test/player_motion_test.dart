import 'package:flame_gallery_runner/src/logic/player_motion.dart';
import 'package:flame_gallery_runner/src/logic/runner_types.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('starts in the middle lane and clamps at the edges', () {
    final motion = PlayerMotion();
    expect(motion.lane, 1);
    motion
      ..move(-1)
      ..move(-1);
    expect(motion.lane, 0);
    motion
      ..move(1)
      ..move(1)
      ..move(1);
    expect(motion.lane, 2);
  });

  test('slide cancels a running jump and restarts the timer', () {
    final motion = PlayerMotion()
      ..jump()
      ..tick(PlayerMotion.jumpDuration / 2);
    expect(motion.slide(), isTrue);
    expect(motion.pose, PlayerPose.sliding);
    expect(motion.poseProgress, 0);
  });

  test('jump lasts its duration, then the player runs again', () {
    final motion = PlayerMotion();
    expect(motion.jump(), isTrue);
    expect(motion.jump(), isFalse);
    motion.tick(PlayerMotion.jumpDuration / 2);
    expect(motion.pose, PlayerPose.jumping);
    expect(motion.poseProgress, closeTo(0.5, 1e-9));
    motion.tick(PlayerMotion.jumpDuration);
    expect(motion.pose, PlayerPose.running);
  });

  test('invulnerability wears off', () {
    final motion = PlayerMotion()..makeInvulnerable();
    expect(motion.isInvulnerable, isTrue);
    motion.tick(PlayerMotion.invulnerableDuration + 0.01);
    expect(motion.isInvulnerable, isFalse);
  });
}
