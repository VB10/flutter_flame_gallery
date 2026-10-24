import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_runner/src/config/runner_config.dart';
import 'package:flame_gallery_runner/src/game/runner_game.dart';
import 'package:flame_gallery_runner/src/view/runner_hud.dart';
import 'package:flutter/material.dart';

/// Three lane endless runner: dodge blocks, jump logs, slide under arches.
///
/// ```dart
/// FlameGallery.show(context, game: const EndlessRunner());
/// ```
final class EndlessRunner extends GalleryGame<RunnerGame> {
  const EndlessRunner({
    this.config = const RunnerConfig(),
    GameStrings? strings,
    super.theme,
  }) : super(strings: strings ?? stringsEn);

  static const id = 'endless_runner';

  static const stringsEn = GameStrings.en(
    title: 'Ruins Runner',
    instructions:
        'Swipe left or right to change lane, up to jump over logs, '
        'down to slide under arches. Grab the coins!',
  );

  static const stringsTr = GameStrings.tr(
    title: 'Harabe Koşusu',
    instructions:
        'Şerit değiştirmek için sağa/sola kaydır, kütüklerin üstünden '
        'atlamak için yukarı, kemerlerin altından kaymak için aşağı '
        'kaydır. Altınları topla!',
  );

  final RunnerConfig config;

  @override
  String get gameId => id;

  @override
  RunnerGame createGame(ColorScheme colors) =>
      RunnerGame(config: config, colors: colors, gameId: id);

  @override
  Widget buildHud(BuildContext context, RunnerGame game) =>
      RunnerHud(game: game);
}
