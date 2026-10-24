import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_match/src/config/match_config.dart';
import 'package:flame_gallery_match/src/game/match_game.dart';
import 'package:flame_gallery_match/src/view/match_hud.dart';
import 'package:flutter/material.dart';

/// Swap neighbouring sweets to line up three or more.
///
/// ```dart
/// FlameGallery.show(context, game: const SweetSwap());
/// ```
final class SweetSwap extends GalleryGame<MatchGame> {
  const SweetSwap({
    this.config = const MatchConfig(),
    GameStrings? strings,
    super.theme,
  }) : super(strings: strings ?? stringsEn);

  static const id = 'sweet_swap';

  static const stringsEn = GameStrings.en(
    title: 'Sweet Swap',
    instructions: 'Swap neighbouring sweets to line up 3 or more.',
  );

  static const stringsTr = GameStrings.tr(
    title: 'Şeker Eşle',
    instructions:
        'Yan yana şekerlerin yerini değiştir, 3 veya daha fazlasını sırala.',
  );

  final MatchConfig config;

  @override
  String get gameId => id;

  @override
  MatchGame createGame(ColorScheme colors) =>
      MatchGame(config: config, colors: colors, gameId: id);

  @override
  Widget buildHud(BuildContext context, MatchGame game) => MatchHud(game: game);
}
