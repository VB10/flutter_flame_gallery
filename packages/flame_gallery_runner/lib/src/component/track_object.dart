import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame_gallery_runner/src/game/runner_game.dart';
import 'package:flame_gallery_runner/src/logic/runner_types.dart';

/// Anything that scrolls down the track in a lane.
sealed class TrackObject extends SpriteComponent
    with HasGameReference<RunnerGame> {
  TrackObject({
    required this.lane,
    required Sprite super.sprite,
    required super.position,
    required super.size,
  }) : super(anchor: Anchor.center);

  final int lane;

  @override
  void update(double dt) {
    super.update(dt);
    position.y += game.speed * dt;
    if (position.y - size.y / 2 > game.size.y) removeFromParent();
  }
}

final class ObstacleComponent extends TrackObject {
  ObstacleComponent({
    required this.kind,
    required super.lane,
    required super.sprite,
    required super.position,
    required super.size,
  });

  final ObstacleKind kind;

  /// Set once the obstacle hit the player or passed them.
  bool resolved = false;
}

final class CoinComponent extends TrackObject {
  CoinComponent({
    required super.lane,
    required super.sprite,
    required super.position,
    required super.size,
  });

  static const _spinRate = 4.0;
  static const _minSpinScale = 0.25;

  double _clock = 0;

  @override
  void update(double dt) {
    super.update(dt);
    _clock += dt;
    scale.x = math.max(_minSpinScale, math.cos(_clock * _spinRate).abs());
  }
}
