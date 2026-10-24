import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_slice/src/config/slice_difficulty.dart';
import 'package:flame_gallery_slice/src/config/slice_item.dart';
import 'package:flutter/foundation.dart';

/// Gameplay rules a host app can tune per campaign.
@immutable
final class SliceConfig {
  const SliceConfig({
    this.timeLimit = const Duration(seconds: 60),
    this.lives,
    this.items = SliceItem.fruits,
    this.bomb = SliceItem.bomb,
    this.bombChance = 0.12,
    this.difficulty = SliceDifficulty.normal,
    this.background,
  }) : assert(
         timeLimit != null || lives != null,
         'Either timeLimit or lives must be set, or the round never ends',
       ),
       assert(lives == null || lives > 0, 'lives must be positive or null'),
       assert(bombChance >= 0 && bombChance <= 1, 'bombChance is 0..1');

  /// `null` → no timer, the round ends only when lives run out.
  final Duration? timeLimit;

  /// Missed items allowed. `null` (default) → misses are free, which suits
  /// timed campaign rounds. Set e.g. `3` for a classic survival mode.
  final int? lives;

  final List<SliceItem> items;

  /// `null` disables bombs.
  final GameAsset? bomb;

  /// Chance that one item of a wave is a bomb.
  final double bombChance;

  final SliceDifficulty difficulty;

  /// Optional full screen background image, stretched to cover.
  final GameAsset? background;

  SliceConfig copyWith({
    Duration? timeLimit,
    int? lives,
    List<SliceItem>? items,
    GameAsset? bomb,
    double? bombChance,
    SliceDifficulty? difficulty,
    GameAsset? background,
  }) => SliceConfig(
    timeLimit: timeLimit ?? this.timeLimit,
    lives: lives ?? this.lives,
    items: items ?? this.items,
    bomb: bomb ?? this.bomb,
    bombChance: bombChance ?? this.bombChance,
    difficulty: difficulty ?? this.difficulty,
    background: background ?? this.background,
  );
}
