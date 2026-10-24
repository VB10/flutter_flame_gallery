import 'package:flame/components.dart';
import 'package:flame_gallery_rhythm/src/game/rhythm_game.dart';

/// A falling note. Its height comes from the song clock, never from summed
/// frame times, so it reaches the hit line exactly on its beat.
final class NoteComponent extends SpriteComponent
    with HasGameReference<RhythmGame> {
  NoteComponent({
    required this.index,
    required this.time,
    required this.lane,
    required super.sprite,
  }) : super(anchor: Anchor.center);

  static const _missedOpacity = 0.35;

  /// Position in the game's note chart.
  final int index;
  final double time;
  final int lane;
  bool _missed = false;

  void markMissed() {
    _missed = true;
    opacity = _missedOpacity;
  }

  @override
  void update(double dt) {
    super.update(dt);
    final layout = game.layout;
    size.setAll(layout.noteSize);
    position.setValues(
      layout.laneCenterX(lane),
      layout.noteY(
        timeToHit: time - game.songTime,
        approachSeconds: game.config.difficulty.approachSeconds,
      ),
    );
    if (_missed && position.y - size.y > game.size.y) removeFromParent();
  }
}
