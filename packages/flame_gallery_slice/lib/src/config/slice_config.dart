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

  /// Nullable fields take a [ValueGetter] so they can also be cleared:
  /// `copyWith(bomb: () => null)` removes bombs, omitting it keeps them.
  SliceConfig copyWith({
    ValueGetter<Duration?>? timeLimit,
    ValueGetter<int?>? lives,
    List<SliceItem>? items,
    ValueGetter<GameAsset?>? bomb,
    double? bombChance,
    SliceDifficulty? difficulty,
    ValueGetter<GameAsset?>? background,
  }) => SliceConfig(
    timeLimit: timeLimit == null ? this.timeLimit : timeLimit(),
    lives: lives == null ? this.lives : lives(),
    items: items ?? this.items,
    bomb: bomb == null ? this.bomb : bomb(),
    bombChance: bombChance ?? this.bombChance,
    difficulty: difficulty ?? this.difficulty,
    background: background == null ? this.background : background(),
  );
}
