import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_runner/src/game/runner_game.dart';
import 'package:flame_gallery_runner/src/testing/runner_keys.dart';
import 'package:flutter/material.dart';

final class RunnerHud extends StatelessWidget {
  const RunnerHud({required this.game, super.key});

  final RunnerGame game;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: GallerySpacing.sm,
    runSpacing: GallerySpacing.sm,
    children: [
      HudValueChip<int>(
        listenable: game.score,
        icon: Icons.star_rounded,
        label: (score) => '$score',
        semanticsId: GalleryKeys.hudScore,
      ),
      HudValueChip<int>(
        listenable: game.coins,
        icon: Icons.monetization_on_rounded,
        label: (coins) => '$coins',
        semanticsId: RunnerKeys.hudCoins,
      ),
      HudValueChip<int>(
        listenable: game.distance,
        icon: Icons.directions_run_rounded,
        label: (meters) => '$meters m',
        semanticsId: RunnerKeys.hudDistance,
      ),
      if (game.config.timeLimit != null)
        HudValueChip<int?>(
          listenable: game.secondsLeft,
          icon: Icons.timer_outlined,
          label: (seconds) => '${seconds ?? 0}',
          semanticsId: GalleryKeys.hudTimer,
        ),
      if (game.config.lives > 1)
        HudLivesChip(
          lives: game.lives,
          maxLives: game.config.lives,
          semanticsId: GalleryKeys.hudLives,
        ),
    ],
  );
}
