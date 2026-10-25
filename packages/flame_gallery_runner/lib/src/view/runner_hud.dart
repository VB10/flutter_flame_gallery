import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_runner/src/game/runner_game.dart';
import 'package:flame_gallery_runner/src/testing/runner_keys.dart';
import 'package:flutter/material.dart';

final class RunnerHud extends StatelessWidget {
  const RunnerHud({required this.game, required this.strings, super.key});

  final RunnerGame game;
  final GameStrings strings;

  @override
  Widget build(BuildContext context) => Wrap(
    spacing: GallerySpacing.sm,
    runSpacing: GallerySpacing.sm,
    children: [
      HudScoreChip(score: game.score),
      HudValueChip<int>(
        listenable: game.coins,
        icon: Icons.monetization_on_rounded,
        label: (coins) => '$coins',
        semanticsId: RunnerKeys.hudCoins,
      ),
      HudValueChip<int>(
        listenable: game.distance,
        icon: Icons.directions_run_rounded,
        label: (meters) => GameStrings.fill(strings.distance, meters),
        semanticsId: RunnerKeys.hudDistance,
      ),
      if (game.config.timeLimit != null)
        HudTimerChip(secondsLeft: game.secondsLeft),
      if (game.config.lives > 1)
        HudLivesChip(
          lives: game.lives,
          maxLives: game.config.lives,
          semanticsId: GalleryKeys.hudLives,
        ),
    ],
  );
}
