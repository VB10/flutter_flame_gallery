import 'package:flame_gallery_core/src/game/gallery_flame_game.dart';
import 'package:flame_gallery_core/src/l10n/game_strings.dart';
import 'package:flame_gallery_core/src/theme/game_theme.dart';
import 'package:flutter/material.dart';

/// Public, immutable description of a playable game: what host apps pass to
/// `FlameGallery.show`. It builds a fresh [GalleryFlameGame] per session.
abstract base class GalleryGame<G extends GalleryFlameGame> {
  const GalleryGame({required this.strings, this.theme = const GameTheme()});

  final GameTheme theme;
  final GameStrings strings;

  String get gameId;

  /// [colors] is [theme] already resolved against the host app.
  G createGame(ColorScheme colors);

  /// In-game HUD (score, lives, timer...). The host adds the pause button.
  Widget buildHud(BuildContext context, G game);

  Widget hudFor(BuildContext context, GalleryFlameGame game) =>
      buildHud(context, game as G);
}
