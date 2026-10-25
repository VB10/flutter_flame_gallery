import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_rhythm/src/audio/rhythm_audio.dart';
import 'package:flame_gallery_rhythm/src/config/rhythm_config.dart';
import 'package:flame_gallery_rhythm/src/config/rhythm_labels.dart';
import 'package:flame_gallery_rhythm/src/game/rhythm_game.dart';
import 'package:flame_gallery_rhythm/src/view/rhythm_hud.dart';
import 'package:flutter/material.dart';

/// Tap the lane when a note reaches the line, in time with the music.
///
/// ```dart
/// FlameGallery.show(context, game: NoteRush(audio: MyAudio()));
/// ```
final class NoteRush extends GalleryGame<RhythmGame> {
  const NoteRush({
    this.config = const RhythmConfig(),
    this.audio,
    this.labels = RhythmLabels.en,
    GameStrings? strings,
    super.theme,
  }) : super(strings: strings ?? stringsEn);

  static const id = 'note_rush';

  static const stringsEn = GameStrings.en(
    title: 'Note Rush',
    instructions: 'Tap the lane when a note reaches the line. Keep the combo!',
  );

  static const stringsTr = GameStrings.tr(
    title: 'Nota Yakala',
    instructions: 'Nota çizgiye geldiğinde o şeride dokun. Kombonu bozma!',
  );

  final RhythmConfig config;

  /// Music backend; `null` plays silently on the game's own clock.
  final RhythmAudio? audio;

  /// Floating judgement texts; [RhythmLabels.tr] ships with the package.
  final RhythmLabels labels;

  @override
  String get gameId => id;

  @override
  RhythmGame createGame(ColorScheme colors) => RhythmGame(
    config: config,
    colors: colors,
    gameId: id,
    audio: audio,
    labels: labels,
  );

  @override
  Widget buildHud(BuildContext context, RhythmGame game) =>
      RhythmHud(game: game, strings: strings);
}
