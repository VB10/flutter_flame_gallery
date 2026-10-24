import 'package:flame_gallery_core/src/theme/gallery_tokens.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Pill shaped HUD container shared by every chip.
final class HudChipFrame extends StatelessWidget {
  const HudChipFrame({required this.child, super.key});

  static const _opacity = 0.85;

  final Widget child;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerHigh
          .withValues(alpha: _opacity),
      borderRadius: BorderRadius.circular(GalleryRadius.lg),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: GallerySpacing.md,
        vertical: GallerySpacing.sm,
      ),
      child: child,
    ),
  );
}

final class HudChip extends StatelessWidget {
  const HudChip({
    required this.icon,
    required this.label,
    this.semanticsId,
    super.key,
  });

  final IconData icon;
  final String label;

  /// `Semantics.identifier` for UI tests; the node's label is [label].
  final String? semanticsId;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      identifier: semanticsId,
      container: true,
      label: label,
      excludeSemantics: true,
      child: HudChipFrame(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: GallerySizes.hudIcon, color: colors.primary),
            const SizedBox(width: GallerySpacing.sm),
            Text(
              label,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: colors.onSurface,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// [HudChip] that rebuilds from a [ValueListenable].
final class HudValueChip<T> extends StatelessWidget {
  const HudValueChip({
    required this.listenable,
    required this.icon,
    required this.label,
    this.semanticsId,
    super.key,
  });

  final ValueListenable<T> listenable;
  final IconData icon;
  final String Function(T value) label;
  final String? semanticsId;

  @override
  Widget build(BuildContext context) => ValueListenableBuilder<T>(
    valueListenable: listenable,
    builder: (_, value, _) =>
        HudChip(icon: icon, label: label(value), semanticsId: semanticsId),
  );
}

/// Hearts for the remaining lives. Semantics label is the remaining count.
final class HudLivesChip extends StatelessWidget {
  const HudLivesChip({
    required this.lives,
    required this.maxLives,
    this.semanticsId,
    super.key,
  });

  final ValueListenable<int?> lives;
  final int maxLives;
  final String? semanticsId;

  @override
  Widget build(BuildContext context) {
    final error = Theme.of(context).colorScheme.error;
    return ValueListenableBuilder<int?>(
      valueListenable: lives,
      builder: (_, lives, _) => Semantics(
        identifier: semanticsId,
        container: true,
        label: '${lives ?? 0}',
        excludeSemantics: true,
        child: HudChipFrame(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < maxLives; i++)
                Icon(
                  i < (lives ?? 0)
                      ? Icons.favorite_rounded
                      : Icons.favorite_border,
                  size: GallerySizes.hudIcon,
                  color: error,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
