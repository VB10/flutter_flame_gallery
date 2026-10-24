import 'dart:math' as math;
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_gallery_slice/src/config/slice_difficulty.dart';
import 'package:flame_gallery_slice/src/game/slice_game.dart';

/// Throws waves of items, faster and bigger as the round goes on.
final class ItemSpawner extends Component with HasGameReference<SliceGame> {
  ItemSpawner({required this.difficulty, required this._random});

  static const _firstWaveDelay = 0.6;

  final SliceDifficulty difficulty;
  final math.Random _random;
  double _cooldown = _firstWaveDelay;
  double _elapsed = 0;

  void reset() {
    _cooldown = _firstWaveDelay;
    _elapsed = 0;
  }

  @override
  void update(double dt) {
    if (!game.isPlaying) return;
    _elapsed += dt;
    _cooldown -= dt;
    if (_cooldown > 0) return;

    final progress = (_elapsed / difficulty.rampSeconds).clamp(0.0, 1.0);
    _cooldown = lerpDouble(
      difficulty.initialInterval,
      difficulty.minInterval,
      progress,
    )!;
    final maxWave = 1 + ((difficulty.maxWaveSize - 1) * progress).round();
    game.spawnWave(1 + _random.nextInt(maxWave));
  }
}
