import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_match/src/game/match_game.dart';
import 'package:flame_gallery_match/src/testing/match_keys.dart';
import 'package:flutter/material.dart';

final class MatchHud extends StatelessWidget {
  const MatchHud({required this.game, super.key});

  final MatchGame game;

  @override
  Widget build(BuildContext context) {
    final target = game.config.targetScore;
    return Wrap(
      spacing: GallerySpacing.sm,
      runSpacing: GallerySpacing.sm,
      children: [
        HudScoreChip(score: game.score),
        if (game.config.moveLimit != null)
          HudValueChip<int?>(
            listenable: game.movesLeft,
            icon: Icons.swap_horiz_rounded,
            label: (moves) => '${moves ?? 0}',
            semanticsId: MatchKeys.hudMoves,
          ),
        if (game.config.timeLimit != null)
          HudTimerChip(secondsLeft: game.secondsLeft),
        if (target != null)
          HudChip(
            icon: Icons.flag_rounded,
            label: '$target',
            semanticsId: MatchKeys.hudTarget,
          ),
      ],
    );
  }
}
