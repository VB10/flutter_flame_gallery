import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_slice/src/config/slice_config.dart';
import 'package:flame_gallery_slice/src/game/slice_game.dart';
import 'package:flame_gallery_slice/src/view/slice_hud.dart';
import 'package:flutter/material.dart';

/// Swipe to slice fruits, avoid bombs.
///
/// ```dart
/// FlameGallery.show(context, game: const FruitSlice());
/// ```
final class FruitSlice extends GalleryGame<SliceGame> {
  const FruitSlice({
    this.config = const SliceConfig(),
    GameStrings? strings,
    super.theme,
  }) : super(strings: strings ?? stringsEn);

  static const id = 'fruit_slice';

  static const stringsEn = GameStrings.en(
    title: 'Fruit Slice',
    instructions: 'Swipe to slice the fruits. Do not touch the bombs!',
  );

  static const stringsTr = GameStrings.tr(
    title: 'Meyve Kes',
    instructions: 'Parmağını kaydırıp meyveleri kes. Bombalara dokunma!',
  );

  final SliceConfig config;

  @override
  String get gameId => id;

  @override
  SliceGame createGame(ColorScheme colors) => SliceGame(
    config: config,
    colors: colors,
    gameId: id,
    comboTemplate: strings.combo,
  );

  @override
  Widget buildHud(BuildContext context, SliceGame game) => SliceHud(game: game);
}
