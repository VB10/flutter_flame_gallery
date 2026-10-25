import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_runner/src/component/player_component.dart';
import 'package:flame_gallery_runner/src/component/row_spawner.dart';
import 'package:flame_gallery_runner/src/component/runner_swipe_input.dart';
import 'package:flame_gallery_runner/src/component/runner_track.dart';
import 'package:flame_gallery_runner/src/component/track_object.dart';
import 'package:flame_gallery_runner/src/config/runner_config.dart';
import 'package:flame_gallery_runner/src/game/runner_layout.dart';
import 'package:flame_gallery_runner/src/game/runner_stat_keys.dart';
import 'package:flame_gallery_runner/src/logic/obstacle_row_planner.dart';
import 'package:flame_gallery_runner/src/logic/player_motion.dart';
import 'package:flame_gallery_runner/src/logic/runner_rules.dart';
import 'package:flame_gallery_runner/src/logic/runner_types.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum RunnerEndCause { outOfLives, timeUp, quit }

final class RunnerGame extends GalleryFlameGame
    with GameEndCause<RunnerEndCause> {
  RunnerGame({
    required this.config,
    required this.colors,
    required super.gameId,
    math.Random? random,
  }) : _planner = ObstacleRowPlanner(random: random),
       _lives = ValueNotifier<int>(config.lives),
       _countdown = RoundCountdown(config.timeLimit);

  /// One screen height of scrolling equals this many metres.
  static const metersPerScreen = 20.0;

  /// Player hit box, as a fraction of the player sprite.
  static const _hitBoxFactor = 0.6;
  static const _shadowAlpha = 0.25;
  static const _coinsPerLine = 3;

  /// Below the track, which draws at -1.
  static const _backgroundPriority = -2;

  /// Longest simulated step. Longer (jank) frames are clamped to it so
  /// obstacles can never tunnel through the hit window.
  static const double _maxStep = 1 / 30;

  final RunnerConfig config;
  final ColorScheme colors;

  final ObstacleRowPlanner _planner;
  final PlayerMotion _motion = PlayerMotion();
  final ValueNotifier<int> _distance = ValueNotifier<int>(0);
  final ValueNotifier<int> _coins = ValueNotifier<int>(0);
  final ValueNotifier<int> _lives;
  final RoundCountdown _countdown;

  late final PlayerComponent _player;
  late final RowSpawner _spawner;
  late final Map<ObstacleKind, Sprite> _obstacleSprites;
  late final Sprite _coinSprite;
  SpriteAnimation? _coinAnimation;
  RunnerLayout _layout = RunnerLayout(Vector2.zero());
  double _elapsed = 0;
  double _traveled = 0;

  ValueListenable<int> get distance => _distance;
  ValueListenable<int> get coins => _coins;
  ValueListenable<int> get lives => _lives;
  ValueListenable<int?> get secondsLeft => _countdown.secondsLeft;

  @internal
  RunnerLayout get layout => _layout;

  /// Pixels scrolled since the round started.
  double get traveled => _traveled;

  /// Current scroll speed in pixels per second.
  /// The world stands still outside of play.
  double get speed =>
      isPlaying ? RunnerRules.speedAt(_elapsed, config.difficulty) * size.y : 0;

  @internal
  PlayerMotion get motion => _motion;

  @override
  Color backgroundColor() => resolveBackground(colors.surface);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layout = RunnerLayout(size);
  }

  @override
  Future<void> onLoad() async {
    final sprites = config.sprites;
    final [block, lowBarrier, highBarrier, coin] = await loadSprites([
      sprites.block,
      sprites.lowBarrier,
      sprites.highBarrier,
      sprites.coin,
    ]);
    _obstacleSprites = {
      ObstacleKind.block: block,
      ObstacleKind.lowBarrier: lowBarrier,
      ObstacleKind.highBarrier: highBarrier,
    };
    _coinSprite = coin;
    _coinAnimation = await sprites.coinAnimation?.load(images);
    await addBackground(config.background, priority: _backgroundPriority);

    final runnerAnimation = await sprites.runnerAnimation?.load(images);
    _player = PlayerComponent(
      sprite:
          runnerAnimation?.frames.first.sprite ??
          await loadSprite(sprites.runner.key),
      motion: _motion,
      animation: runnerAnimation,
    );
    _spawner = RowSpawner(difficulty: config.difficulty, planner: _planner);
    await addAll([
      RunnerTrack(
        pathColor: colors.surfaceContainer,
        stripeColor: colors.outlineVariant,
      ),
      PlayerShadow(
        player: _player,
        color: colors.shadow.withValues(alpha: _shadowAlpha),
      ),
      _player,
      _spawner,
      RunnerSwipeInput(),
    ]);
    _player.snapToLane();
    await super.onLoad();
  }

  @override
  void onRoundStart() {
    removeAll(children.whereType<TrackObject>());
    _motion.reset();
    _player.snapToLane();
    _spawner.reset();
    _elapsed = 0;
    _traveled = 0;
    _distance.value = 0;
    _coins.value = 0;
    _lives.value = config.lives;
    _countdown.reset();
  }

  @override
  void update(double dt) {
    final step = math.min(dt, _maxStep);
    super.update(step);
    if (!isPlaying) return;
    _run(step);
    _checkObstacles();
    if (isPlaying) _collectCoins();
    if (isPlaying && _countdown.tick(step)) finishWith(RunnerEndCause.timeUp);
  }

  @override
  Map<String, Object> collectStats() => {
    RunnerStatKeys.distance: _distance.value,
    RunnerStatKeys.coins: _coins.value,
    ...super.collectStats(),
  };

  @internal
  void onSwipe(SwipeDirection direction) {
    if (!isPlaying) return;
    switch (direction) {
      case SwipeDirection.left:
        _motion.move(-1);
      case SwipeDirection.right:
        _motion.move(1);
      case SwipeDirection.up:
        _motion.jump();
        sounds.play(GameSoundCue.jump);
      case SwipeDirection.down:
        _motion.slide();
    }
  }

  /// Adds [row] at [y] (default: just above the top edge).
  @internal
  void spawnRow(RunnerRow row, {double? y}) {
    final rowY = y ?? -_layout.laneWidth;
    for (final (lane, kind) in row.obstacles.indexed) {
      if (kind != null) add(_obstacle(kind, lane, rowY));
    }
    final coinLane = row.coinLane;
    if (coinLane != null) addAll(_coinLine(coinLane, rowY));
  }

  ObstacleComponent _obstacle(ObstacleKind kind, int lane, double y) =>
      ObstacleComponent(
        kind: kind,
        lane: lane,
        sprite: _obstacleSprites[kind]!,
        position: Vector2(_layout.laneCenterX(lane), y),
        size: kind == ObstacleKind.block
            ? _layout.blockSize
            : _layout.barrierSize,
      );

  /// [_coinsPerLine] coins stacked upward from [y].
  List<CoinComponent> _coinLine(int lane, double y) => [
    for (var i = 0; i < _coinsPerLine; i++)
      CoinComponent(
        lane: lane,
        sprite: _coinSprite,
        animation: _coinAnimation,
        position: Vector2(
          _layout.laneCenterX(lane),
          y - i * _layout.coinSpacing,
        ),
        size: _layout.coinSize,
      ),
  ];

  /// Scrolls the world and turns the distance into metres.
  void _run(double step) {
    _elapsed += step;
    _traveled += speed * step;
    final meters = (_traveled / size.y * metersPerScreen).floor();
    if (meters == _distance.value) return;
    _distance.value = meters;
    _syncScore();
  }

  /// Each obstacle is resolved once: when it hits the player, or when it has
  /// scrolled past them.
  void _checkObstacles() {
    final lane = _player.occupiedLane;
    for (final obstacle in children.whereType<ObstacleComponent>()) {
      if (obstacle.resolved) continue;
      if (_hasPassedPlayer(obstacle)) {
        obstacle.resolved = true;
        continue;
      }
      if (obstacle.lane != lane || !_touchesPlayer(obstacle)) continue;
      if (!RunnerRules.collides(obstacle.kind, _motion.pose)) continue;
      obstacle.resolved = true;
      if (_motion.isInvulnerable) continue;
      _hit();
      if (!isPlaying) return;
    }
  }

  void _collectCoins() {
    final lane = _player.occupiedLane;
    for (final coin in children.whereType<CoinComponent>()) {
      if (coin.lane != lane || coin.isRemoving || !_touchesPlayer(coin)) {
        continue;
      }
      coin.removeFromParent();
      _coins.value++;
      sounds.play(GameSoundCue.coin);
      _syncScore();
    }
  }

  /// Half the height of the player's hit box.
  double get _reach => _layout.playerSize * _hitBoxFactor / 2;

  bool _hasPassedPlayer(TrackObject object) =>
      object.y - _player.y - object.size.y / 2 > _reach;

  bool _touchesPlayer(TrackObject object) =>
      (object.y - _player.y).abs() <= object.size.y / 2 + _reach;

  void _hit() {
    sounds.play(GameSoundCue.hit);
    _lives.value = math.max(0, _lives.value - 1);
    if (_lives.value == 0) {
      finishWith(RunnerEndCause.outOfLives);
    } else {
      _motion.makeInvulnerable();
    }
  }

  /// Score is derived from distance and coins; [addScore] gets the change.
  void _syncScore() => addScore(
    RunnerRules.score(
          meters: _distance.value,
          coins: _coins.value,
          coinValue: config.coinValue,
        ) -
        score.value,
  );

  @override
  void onRemove() {
    _distance.dispose();
    _coins.dispose();
    _lives.dispose();
    _countdown.dispose();
    super.onRemove();
  }
}
