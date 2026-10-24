import 'package:flame_gallery_core/src/l10n/game_strings.dart';
import 'package:flame_gallery_core/src/testing/gallery_keys.dart';
import 'package:flame_gallery_core/src/theme/gallery_tokens.dart';
import 'package:flame_gallery_core/src/widget/overlay_panel.dart';
import 'package:flutter/material.dart';

final class GameOverOverlay extends StatelessWidget {
  const GameOverOverlay({
    required this.strings,
    required this.score,
    required this.onPlayAgain,
    required this.onClose,
    super.key,
  });

  final GameStrings strings;
  final int score;
  final VoidCallback onPlayAgain;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OverlayPanel(
      semanticsId: GalleryKeys.gameOverPanel,
      children: [
        Text(
          strings.gameOver,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall,
        ),
        const SizedBox(height: GallerySpacing.md),
        Text(
          strings.score,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelLarge,
        ),
        Semantics(
          identifier: GalleryKeys.finalScore,
          label: '$score',
          excludeSemantics: true,
          child: Text(
            '$score',
            textAlign: TextAlign.center,
            style: theme.textTheme.displayMedium?.copyWith(
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: GallerySpacing.lg),
        Semantics(
          identifier: GalleryKeys.playAgainButton,
          child: FilledButton(
            onPressed: onPlayAgain,
            child: Text(strings.playAgain),
          ),
        ),
        const SizedBox(height: GallerySpacing.sm),
        Semantics(
          identifier: GalleryKeys.closeButton,
          child: TextButton(onPressed: onClose, child: Text(strings.close)),
        ),
      ],
    );
  }
}
