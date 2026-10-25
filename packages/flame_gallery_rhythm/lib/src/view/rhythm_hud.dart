import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_rhythm/src/game/rhythm_game.dart';
import 'package:flame_gallery_rhythm/src/testing/rhythm_keys.dart';
import 'package:flutter/material.dart';

/// Score, combo and accuracy; hearts for the misses left when a miss limit is
/// set (one heart per allowed miss, under `GalleryKeys.hudLives`).
final class RhythmHud extends StatelessWidget {
  const RhythmHud({required this.game, required this.strings, super.key});

  final RhythmGame game;
  final GameStrings strings;

  @override
  Widget build(BuildContext context) {
    final missLimit = game.config.missLimit;
    return Wrap(
      spacing: GallerySpacing.sm,
      runSpacing: GallerySpacing.sm,
      children: [
        HudScoreChip(score: game.score),
        HudValueChip<int>(
          listenable: game.combo,
          icon: Icons.bolt_rounded,
          label: (combo) => GameStrings.fill(strings.combo, combo),
          semanticsId: RhythmKeys.hudCombo,
        ),
        HudValueChip<int>(
          listenable: game.accuracy,
          icon: Icons.track_changes_rounded,
          label: (accuracy) => GameStrings.fill(strings.accuracy, accuracy),
          semanticsId: RhythmKeys.hudAccuracy,
        ),
        if (missLimit != null)
          HudLivesChip(
            lives: game.missesLeft,
            maxLives: missLimit,
            semanticsId: GalleryKeys.hudLives,
          ),
      ],
    );
  }
}
