import 'dart:math' as math;

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_runner/src/component/player_component.dart';
import 'package:flame_gallery_runner/src/component/row_spawner.dart';
import 'package:flame_gallery_runner/src/component/runner_swipe_input.dart';
import 'package:flame_gallery_runner/src/component/runner_track.dart';
import 'package:flame_gallery_runner/src/component/track_object.dart';
import 'package:flame_gallery_runner/src/config/runner_config.dart';
import 'package:flame_gallery_runner/src/game/runner_layout.dart';
import 'package:flame_gallery_runner/src/logic/obstacle_row_planner.dart';
import 'package:flame_gallery_runner/src/logic/player_motion.dart';
import 'package:flame_gallery_runner/src/logic/runner_rules.dart';
import 'package:flame_gallery_runner/src/logic/runner_types.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum RunnerEndCause { outOfLives, timeUp, quit }

final class RunnerGame extends GalleryFlameGame {
  RunnerGame({
    required this.config,
    required this.colors,
    required super.gameId,
    math.Random? random,
  }) : _planner = ObstacleRowPlanner(random: random),
       _lives = ValueNotifier<int>(config.lives),
       _secondsLeft = ValueNotifier<int?>(_ceilSeconds(config.timeLimit)) {
    images = Images(prefix: '');
  }

  /// One screen height of scrolling equals this many metres.
  static const metersPerScreen = 20.0;

  /// Player hit box, as a fraction of the player sprite.
  static const _hitBoxFactor = 0.6;
  static const _shadowAlpha = 0.25;
  static const _coinsPerLine = 3;

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
  final ValueNotifier<int?> _secondsLeft;

  late final PlayerComponent _player;
  late final RowSpawner _spawner;
  late final Map<ObstacleKind, Sprite> _obstacleSprites;
  late final Sprite _coinSprite;
  RunnerLayout _layout = RunnerLayout(Vector2.zero());
  double _elapsed = 0;
  double _traveled = 0;
  double _timeLeft = 0;
  RunnerEndCause? _endCause;

  ValueListenable<int> get distance => _distance;
  ValueListenable<int> get coins => _coins;
  ValueListenable<int> get lives => _lives;
  ValueListenable<int?> get secondsLeft => _secondsLeft;

  RunnerLayout get layout => _layout;

  /// Pixels scrolled since the round started.
  double get traveled => _traveled;

  /// Current scroll speed in pixels per second.
  /// The world stands still outside of play.
  double get speed =>
      isPlaying ? RunnerRules.speedAt(_elapsed, config.difficulty) * size.y : 0;

  PlayerMotion get motion => _motion;

  @override
  Color backgroundColor() => colors.surface;

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layout = RunnerLayout(size);
  }

  @override
  Future<void> onLoad() async {
    final sprites = config.sprites;
    Future<Sprite> load(GameAsset asset) async =>
        Sprite(await images.load(asset.key));

    _obstacleSprites = {
      ObstacleKind.block: await load(sprites.block),
      ObstacleKind.lowBarrier: await load(sprites.lowBarrier),
      ObstacleKind.highBarrier: await load(sprites.highBarrier),
    };
    _coinSprite = await load(sprites.coin);
    final background = config.background;
    if (background != null) {
      await add(_Background(sprite: await load(background)));
    }

    _player = PlayerComponent(
      sprite: await load(sprites.runner),
      motion: _motion,
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
    _endCause = null;
    _timeLeft =
        (config.timeLimit?.inMilliseconds ?? 0) /
        Duration.millisecondsPerSecond;
    _distance.value = 0;
    _coins.value = 0;
    _lives.value = config.lives;
    _secondsLeft.value = _ceilSeconds(config.timeLimit);
  }

  @override
  void update(double dt) {
    final step = math.min(dt, _maxStep);
    super.update(step);
    if (!isPlaying) return;
    _elapsed += step;
    _traveled += speed * step;
    final meters = (_traveled / size.y * metersPerScreen).floor();
    if (meters != _distance.value) {
      _distance.value = meters;
      _syncScore();
    }
    _checkCollisions();
    if (!isPlaying || config.timeLimit == null) return;
    _timeLeft -= step;
    final seconds = math.max(0, _timeLeft.ceil());
    if (seconds != _secondsLeft.value) _secondsLeft.value = seconds;
    if (_timeLeft <= 0) _end(RunnerEndCause.timeUp);
  }

  @override
  Map<String, Object> collectStats() => {
    'distance': _distance.value,
    'coins': _coins.value,
    'endedBy': (_endCause ?? RunnerEndCause.quit).name,
  };

  void onSwipe(SwipeDirection direction) {
    if (!isPlaying) return;
    switch (direction) {
      case SwipeDirection.left:
        _motion.move(-1);
      case SwipeDirection.right:
        _motion.move(1);
      case SwipeDirection.up:
        _motion.jump();
      case SwipeDirection.down:
        _motion.slide();
    }
  }

  /// Adds [row] at [y] (default: just above the top edge).
  void spawnRow(RunnerRow row, {double? y}) {
    final rowY = y ?? -_layout.laneWidth;
    for (var lane = 0; lane < row.obstacles.length; lane++) {
      final kind = row.obstacles[lane];
      if (kind == null) continue;
      add(
        ObstacleComponent(
          kind: kind,
          lane: lane,
          sprite: _obstacleSprites[kind]!,
          position: Vector2(_layout.laneCenterX(lane), rowY),
          size: kind == ObstacleKind.block
              ? _layout.blockSize
              : _layout.barrierSize,
        ),
      );
    }
    final coinLane = row.coinLane;
    if (coinLane == null) return;
    for (var i = 0; i < _coinsPerLine; i++) {
      add(
        CoinComponent(
          lane: coinLane,
          sprite: _coinSprite,
          position: Vector2(
            _layout.laneCenterX(coinLane),
            rowY - i * _layout.coinSpacing,
          ),
          size: _layout.coinSize,
        ),
      );
    }
  }

  void _checkCollisions() {
    final lane = _player.occupiedLane;
    final reach = _layout.playerSize * _hitBoxFactor / 2;

    for (final obstacle in children.whereType<ObstacleComponent>().toList()) {
      if (obstacle.resolved) continue;
      final dy = obstacle.y - _player.y;
      if (dy - obstacle.size.y / 2 > reach) {
        obstacle.resolved = true;
        continue;
      }
      final overlaps = dy.abs() <= obstacle.size.y / 2 + reach;
      if (obstacle.lane != lane || !overlaps) continue;
      if (!RunnerRules.collides(obstacle.kind, _motion.pose)) continue;
      obstacle.resolved = true;
      if (_motion.isInvulnerable) continue;
      _hit();
      if (!isPlaying) return;
    }

    for (final coin in children.whereType<CoinComponent>().toList()) {
      final overlaps = (coin.y - _player.y).abs() <= coin.size.y / 2 + reach;
      if (coin.lane != lane || !overlaps || coin.isRemoving) continue;
      coin.removeFromParent();
      _coins.value++;
      _syncScore();
    }
  }

  void _hit() {
    _lives.value = math.max(0, _lives.value - 1);
    if (_lives.value == 0) {
      _end(RunnerEndCause.outOfLives);
    } else {
      _motion.makeInvulnerable();
    }
  }

  void _syncScore() => addScore(
    RunnerRules.score(
          meters: _distance.value,
          coins: _coins.value,
          coinValue: config.coinValue,
        ) -
        score.value,
  );

  void _end(RunnerEndCause cause) {
    _endCause = cause;
    finish();
  }

  static int? _ceilSeconds(Duration? duration) => duration == null
      ? null
      : (duration.inMilliseconds / Duration.millisecondsPerSecond).ceil();

  @override
  void onRemove() {
    _distance.dispose();
    _coins.dispose();
    _lives.dispose();
    _secondsLeft.dispose();
    super.onRemove();
  }
}

final class _Background extends SpriteComponent {
  _Background({required super.sprite}) : super(priority: -2);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }
}
