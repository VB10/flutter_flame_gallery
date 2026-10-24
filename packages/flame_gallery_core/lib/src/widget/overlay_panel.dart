import 'package:flame_gallery_core/src/theme/gallery_tokens.dart';
import 'package:flutter/material.dart';

/// Dimmed full screen scrim with a centered card. Used by every menu overlay.
final class OverlayPanel extends StatelessWidget {
  const OverlayPanel({required this.children, this.semanticsId, super.key});

  static const _scrimOpacity = 0.55;

  final List<Widget> children;
  final String? semanticsId;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      identifier: semanticsId,
      container: true,
      child: ColoredBox(
        color: colors.scrim.withValues(alpha: _scrimOpacity),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(GallerySpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: GallerySizes.panelMaxWidth,
              ),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: colors.surfaceContainer,
                  borderRadius: BorderRadius.circular(GalleryRadius.lg),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(GallerySpacing.lg),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
