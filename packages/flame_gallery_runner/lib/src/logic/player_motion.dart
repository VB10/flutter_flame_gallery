import 'dart:math' as math;

import 'package:flame_gallery_runner/src/logic/obstacle_row_planner.dart';
import 'package:flame_gallery_runner/src/logic/runner_types.dart';

/// Lane, pose and invulnerability of the player, independent of rendering.
final class PlayerMotion {
  PlayerMotion({this.laneCount = ObstacleRowPlanner.laneCount})
    : _lane = laneCount ~/ 2;

  static const jumpDuration = 0.65;
  static const slideDuration = 0.65;
  static const invulnerableDuration = 1.5;

  final int laneCount;
  int _lane;
  PlayerPose _pose = PlayerPose.running;
  double _poseRemaining = 0;
  double _invulnerableRemaining = 0;

  int get lane => _lane;
  PlayerPose get pose => _pose;
  bool get isInvulnerable => _invulnerableRemaining > 0;
  double get invulnerableRemaining => _invulnerableRemaining;

  /// 0 → 1 over the current jump or slide; 0 while running.
  double get poseProgress => switch (_pose) {
    PlayerPose.running => 0,
    PlayerPose.jumping => 1 - _poseRemaining / jumpDuration,
    PlayerPose.sliding => 1 - _poseRemaining / slideDuration,
  };

  void reset() {
    _lane = laneCount ~/ 2;
    _pose = PlayerPose.running;
    _poseRemaining = 0;
    _invulnerableRemaining = 0;
  }

  void move(int direction) =>
      _lane = (_lane + direction).clamp(0, laneCount - 1);

  bool jump() => _startPose(PlayerPose.jumping, jumpDuration);

  bool slide() => _startPose(PlayerPose.sliding, slideDuration);

  void makeInvulnerable() => _invulnerableRemaining = invulnerableDuration;

  void tick(double dt) {
    _invulnerableRemaining = math.max(0, _invulnerableRemaining - dt);
    if (_pose == PlayerPose.running) return;
    _poseRemaining -= dt;
    if (_poseRemaining <= 0) {
      _pose = PlayerPose.running;
      _poseRemaining = 0;
    }
  }

  /// A jump cancels a slide and vice versa, so back-to-back rows that need
  /// opposite moves stay survivable at top speed.
  bool _startPose(PlayerPose pose, double duration) {
    if (_pose == pose) return false;
    _pose = pose;
    _poseRemaining = duration;
    return true;
  }
}
