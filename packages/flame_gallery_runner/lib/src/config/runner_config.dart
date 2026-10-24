import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_runner/src/config/runner_difficulty.dart';
import 'package:flame_gallery_runner/src/config/runner_sprites.dart';
import 'package:flutter/foundation.dart';

/// Gameplay rules a host app can tune per campaign.
@immutable
final class RunnerConfig {
  const RunnerConfig({
    this.timeLimit,
    this.lives = 1,
    this.coinValue = 5,
    this.difficulty = RunnerDifficulty.normal,
    this.sprites = const RunnerSprites(),
    this.background,
  }) : assert(lives > 0, 'lives must be positive'),
       assert(coinValue >= 0, 'coinValue must not be negative');

  /// `null` (default) → endless, the round ends only when lives run out.
  final Duration? timeLimit;

  /// Hits allowed before the round ends.
  final int lives;

  /// Points per collected coin. Every metre run is worth one point.
  final int coinValue;

  final RunnerDifficulty difficulty;
  final RunnerSprites sprites;

  /// Optional full screen background image, stretched to cover.
  final GameAsset? background;
}
