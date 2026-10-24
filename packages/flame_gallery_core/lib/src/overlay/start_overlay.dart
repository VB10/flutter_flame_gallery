import 'package:flame_gallery_core/src/l10n/game_strings.dart';
import 'package:flame_gallery_core/src/testing/gallery_keys.dart';
import 'package:flame_gallery_core/src/theme/gallery_tokens.dart';
import 'package:flame_gallery_core/src/widget/overlay_panel.dart';
import 'package:flutter/material.dart';

final class StartOverlay extends StatelessWidget {
  const StartOverlay({
    required this.strings,
    required this.onStart,
    required this.onClose,
    this.logo,
    super.key,
  });

  final GameStrings strings;
  final ImageProvider? logo;
  final VoidCallback onStart;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final logo = this.logo;
    return OverlayPanel(
      semanticsId: GalleryKeys.startPanel,
      children: [
        if (logo != null) ...[
          Image(image: logo, height: GallerySizes.logo),
          const SizedBox(height: GallerySpacing.md),
        ],
        Text(
          strings.title,
          textAlign: TextAlign.center,
          style: textTheme.headlineSmall,
        ),
        const SizedBox(height: GallerySpacing.sm),
        Text(
          strings.instructions,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium,
        ),
        const SizedBox(height: GallerySpacing.lg),
        Semantics(
          identifier: GalleryKeys.startButton,
          child: FilledButton(onPressed: onStart, child: Text(strings.start)),
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
