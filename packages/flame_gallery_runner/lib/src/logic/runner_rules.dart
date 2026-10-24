import 'dart:ui';

import 'package:flame_gallery_runner/src/config/runner_difficulty.dart';
import 'package:flame_gallery_runner/src/logic/runner_types.dart';

/// Pure gameplay rules, kept free of Flame so they are trivially testable.
abstract final class RunnerRules {
  static bool collides(ObstacleKind kind, PlayerPose pose) => switch (kind) {
    ObstacleKind.block => true,
    ObstacleKind.lowBarrier => pose != PlayerPose.jumping,
    ObstacleKind.highBarrier => pose != PlayerPose.sliding,
  };

  static int score({
    required int meters,
    required int coins,
    required int coinValue,
  }) => meters + coins * coinValue;

  /// Scroll speed in screen heights per second after [elapsedSeconds].
  static double speedAt(double elapsedSeconds, RunnerDifficulty difficulty) {
    final progress = (elapsedSeconds / difficulty.rampSeconds).clamp(0.0, 1.0);
    return lerpDouble(difficulty.startSpeed, difficulty.maxSpeed, progress)!;
  }
}
