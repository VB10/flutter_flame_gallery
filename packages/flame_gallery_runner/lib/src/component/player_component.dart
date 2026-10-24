import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_gallery_runner/src/game/runner_game.dart';
import 'package:flame_gallery_runner/src/logic/player_motion.dart';
import 'package:flame_gallery_runner/src/logic/runner_types.dart';

/// Draws the player from its [PlayerMotion]: lane easing, jump scale, slide
/// squash and the post-hit blink.
final class PlayerComponent extends SpriteComponent
    with HasGameReference<RunnerGame> {
  PlayerComponent({required super.sprite, required this.motion})
    : super(anchor: Anchor.center, priority: 2);

  static const _laneEaseRate = 14.0;
  static const _jumpScale = 0.35;
  static const _slideScaleX = 1.15;
  static const _slideScaleY = 0.55;
  static const _blinkRate = 12.0;
  static const _blinkOpacity = 0.3;

  final PlayerMotion motion;
  double _blinkClock = 0;

  /// Lane used for collisions: the one the sprite currently stands in.
  int get occupiedLane => game.layout.laneAt(position.x);

  void snapToLane() => position.setValues(
    game.layout.laneCenterX(motion.lane),
    game.layout.playerY,
  );

  @override
  void update(double dt) {
    super.update(dt);
    motion.tick(dt);
    final layout = game.layout;
    size.setAll(layout.playerSize);
    final targetX = layout.laneCenterX(motion.lane);
    position
      ..x += (targetX - position.x) * math.min(1, dt * _laneEaseRate)
      ..y = layout.playerY;

    switch (motion.pose) {
      case PlayerPose.running:
        scale.setAll(1);
      case PlayerPose.jumping:
        scale.setAll(1 + _jumpScale * math.sin(math.pi * motion.poseProgress));
      case PlayerPose.sliding:
        scale.setValues(_slideScaleX, _slideScaleY);
    }

    if (motion.isInvulnerable) {
      _blinkClock += dt;
      opacity = (_blinkClock * _blinkRate).floor().isEven ? _blinkOpacity : 1;
    } else {
      _blinkClock = 0;
      opacity = 1;
    }
  }
}

/// Ground shadow that stays put and fades while the player is airborne.
final class PlayerShadow extends Component with HasGameReference<RunnerGame> {
  PlayerShadow({required this.player, required Color color})
    : _paint = Paint()..color = color,
      _baseAlpha = color.a,
      super(priority: 1);

  static const _widthFactor = 0.7;
  static const _heightFactor = 0.3;
  static const _yOffsetFactor = 0.35;
  static const _airborneFade = 0.6;

  final PlayerComponent player;
  final Paint _paint;
  final double _baseAlpha;

  @override
  void render(Canvas canvas) {
    final size = game.layout.playerSize;
    final lift = player.motion.pose == PlayerPose.jumping
        ? math.sin(math.pi * player.motion.poseProgress)
        : 0.0;
    _paint.color = _paint.color.withValues(
      alpha: _baseAlpha * (1 - _airborneFade * lift),
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(player.x, player.y + size * _yOffsetFactor),
        width: size * _widthFactor,
        height: size * _heightFactor,
      ),
      _paint,
    );
  }
}
