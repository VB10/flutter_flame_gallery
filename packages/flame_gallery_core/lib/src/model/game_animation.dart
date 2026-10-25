import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame_gallery_core/src/model/game_asset.dart';
import 'package:flutter/foundation.dart';

/// A sprite sheet laid out as one horizontal strip of [frames] equal frames.
@immutable
final class GameAnimation {
  const GameAnimation(
    this.sheet, {
    required this.frames,
    this.stepTime = 0.1,
    this.loop = true,
  }) : assert(frames > 0, 'frames must be positive'),
       assert(stepTime > 0, 'stepTime must be positive');

  final GameAsset sheet;
  final int frames;

  /// Seconds each frame stays on screen.
  final double stepTime;
  final bool loop;

  Future<SpriteAnimation> load(Images images) async {
    final image = await images.load(sheet.key);
    return SpriteAnimation.fromFrameData(
      image,
      SpriteAnimationData.sequenced(
        amount: frames,
        stepTime: stepTime,
        textureSize: Vector2(image.width / frames, image.height.toDouble()),
        loop: loop,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      other is GameAnimation &&
      other.sheet == sheet &&
      other.frames == frames &&
      other.stepTime == stepTime &&
      other.loop == loop;

  @override
  int get hashCode => Object.hash(sheet, frames, stepTime, loop);
}
