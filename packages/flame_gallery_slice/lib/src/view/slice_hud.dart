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
        HudValueChip<int>(
          listenable: game.score,
          icon: Icons.star_rounded,
          label: (score) => '$score',
          semanticsId: GalleryKeys.hudScore,
        ),
        if (game.config.timeLimit != null)
          HudValueChip<int?>(
            listenable: game.secondsLeft,
            icon: Icons.timer_outlined,
            label: (seconds) => '${seconds ?? 0}',
            semanticsId: GalleryKeys.hudTimer,
          ),
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
