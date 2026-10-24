import 'package:flame_gallery_core/src/testing/gallery_keys.dart';
import 'package:flame_gallery_core/src/theme/gallery_tokens.dart';
import 'package:flutter/material.dart';

/// Top bar shown while playing: the game's own HUD plus a pause button.
final class HudOverlay extends StatelessWidget {
  const HudOverlay({
    required this.hud,
    required this.pauseLabel,
    required this.onPause,
    super.key,
  });

  final Widget hud;
  final String pauseLabel;
  final VoidCallback onPause;

  @override
  Widget build(BuildContext context) => SafeArea(
    child: Padding(
      padding: const EdgeInsets.all(GallerySpacing.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: hud),
          Semantics(
            identifier: GalleryKeys.pauseButton,
            child: IconButton.filledTonal(
              onPressed: onPause,
              tooltip: pauseLabel,
              icon: const Icon(Icons.pause_rounded),
            ),
          ),
        ],
      ),
    ),
  );
}
