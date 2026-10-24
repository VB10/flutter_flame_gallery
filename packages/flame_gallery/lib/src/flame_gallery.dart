import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flutter/material.dart';

/// Entry point for host apps.
abstract final class FlameGallery {
  /// Opens [game] full screen and completes with the last [GameResult], or
  /// `null` if the player closed it before starting a round.
  static Future<GameResult?> show(
    BuildContext context, {
    required GalleryGame game,
    ValueChanged<GameEvent>? onEvent,
    bool useRootNavigator = true,
    bool immersive = true,
  }) => Navigator.of(context, rootNavigator: useRootNavigator).push(
    MaterialPageRoute<GameResult>(
      fullscreenDialog: true,
      builder: (_) =>
          GameHostPage(game: game, onEvent: onEvent, immersive: immersive),
    ),
  );
}
