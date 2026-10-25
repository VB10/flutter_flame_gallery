import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_slice/src/game/slice_game.dart';
import 'package:flutter/material.dart';

final class SliceHud extends StatelessWidget {
  const SliceHud({required this.game, super.key});

  final SliceGame game;

  @override
  Widget build(BuildContext context) {
    final maxLives = game.config.lives;
    return Wrap(
      spacing: GallerySpacing.sm,
      runSpacing: GallerySpacing.sm,
      children: [
        HudScoreChip(score: game.score),
        if (game.config.timeLimit != null)
          HudTimerChip(secondsLeft: game.secondsLeft),
        if (maxLives != null)
          HudLivesChip(
            lives: game.lives,
            maxLives: maxLives,
            semanticsId: GalleryKeys.hudLives,
          ),
      ],
    );
  }
}
