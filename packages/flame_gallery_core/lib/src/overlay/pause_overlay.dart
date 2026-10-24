import 'package:flame_gallery_core/src/l10n/game_strings.dart';
import 'package:flame_gallery_core/src/testing/gallery_keys.dart';
import 'package:flame_gallery_core/src/theme/gallery_tokens.dart';
import 'package:flame_gallery_core/src/widget/overlay_panel.dart';
import 'package:flutter/material.dart';

final class PauseOverlay extends StatelessWidget {
  const PauseOverlay({
    required this.strings,
    required this.onResume,
    required this.onClose,
    super.key,
  });

  final GameStrings strings;
  final VoidCallback onResume;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) => OverlayPanel(
    semanticsId: GalleryKeys.pausePanel,
    children: [
      Text(
        strings.paused,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.headlineSmall,
      ),
      const SizedBox(height: GallerySpacing.lg),
      Semantics(
        identifier: GalleryKeys.resumeButton,
        child: FilledButton(onPressed: onResume, child: Text(strings.resume)),
      ),
      const SizedBox(height: GallerySpacing.sm),
      Semantics(
        identifier: GalleryKeys.closeButton,
        child: TextButton(onPressed: onClose, child: Text(strings.close)),
      ),
    ],
  );
}
