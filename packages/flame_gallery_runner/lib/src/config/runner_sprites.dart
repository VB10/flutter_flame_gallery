import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flutter/foundation.dart';

const _package = 'flame_gallery_runner';

/// Every image the runner draws. Override any of them to rebrand the game.
@immutable
final class RunnerSprites {
  const RunnerSprites({
    this.runner = defaultRunner,
    this.coin = defaultCoin,
    this.block = defaultBlock,
    this.lowBarrier = defaultLowBarrier,
    this.highBarrier = defaultHighBarrier,
    this.runnerAnimation,
    this.coinAnimation,
  });

  static const defaultRunner = GameAsset(
    'assets/images/runner.png',
    package: _package,
  );
  static const defaultCoin = GameAsset(
    'assets/images/coin.png',
    package: _package,
  );
  static const defaultBlock = GameAsset(
    'assets/images/block.png',
    package: _package,
  );
  static const defaultLowBarrier = GameAsset(
    'assets/images/low_barrier.png',
    package: _package,
  );
  static const defaultHighBarrier = GameAsset(
    'assets/images/high_barrier.png',
    package: _package,
  );

  /// Top-down player, facing the top of the screen.
  final GameAsset runner;
  final GameAsset coin;

  /// Animated sheets that replace [runner] / [coin] when set.
  final GameAnimation? runnerAnimation;
  final GameAnimation? coinAnimation;

  /// Fills a lane; dodge by changing lane.
  final GameAsset block;

  /// Jump over it.
  final GameAsset lowBarrier;

  /// Slide under it.
  final GameAsset highBarrier;
}
