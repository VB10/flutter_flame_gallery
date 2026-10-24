import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_rhythm/src/config/rhythm_difficulty.dart';
import 'package:flame_gallery_rhythm/src/config/rhythm_song.dart';
import 'package:flame_gallery_rhythm/src/config/rhythm_sprites.dart';
import 'package:flutter/foundation.dart';

/// Gameplay rules a host app can tune per campaign.
@immutable
final class RhythmConfig {
  const RhythmConfig({
    this.song = RhythmSong.demo,
    this.lanes = 4,
    this.difficulty = RhythmDifficulty.normal,
    this.missLimit,
    this.noteSprites = RhythmSprites.notes,
    this.background,
  }) : assert(lanes >= minLanes && lanes <= maxLanes, 'lanes must be 2..6'),
       assert(missLimit == null || missLimit > 0, 'missLimit must be > 0');

  static const minLanes = 2;
  static const maxLanes = 6;

  final RhythmSong song;

  /// Must cover every note lane of [song].
  final int lanes;

  final RhythmDifficulty difficulty;

  /// Misses allowed before the round ends. `null` → play the whole song.
  final int? missLimit;

  /// Note sprite per lane; reused cyclically when there are more lanes.
  final List<GameAsset> noteSprites;

  /// Optional full screen background image, stretched to cover.
  final GameAsset? background;

  RhythmConfig copyWith({
    RhythmSong? song,
    int? lanes,
    RhythmDifficulty? difficulty,
    int? missLimit,
    List<GameAsset>? noteSprites,
    GameAsset? background,
  }) => RhythmConfig(
    song: song ?? this.song,
    lanes: lanes ?? this.lanes,
    difficulty: difficulty ?? this.difficulty,
    missLimit: missLimit ?? this.missLimit,
    noteSprites: noteSprites ?? this.noteSprites,
    background: background ?? this.background,
  );
}
