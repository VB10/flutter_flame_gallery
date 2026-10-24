import 'dart:math' as math;

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_slice/src/component/blade_trail.dart';
import 'package:flame_gallery_slice/src/component/item_spawner.dart';
import 'package:flame_gallery_slice/src/component/slice_item_component.dart';
import 'package:flame_gallery_slice/src/component/sliced_half_component.dart';
import 'package:flame_gallery_slice/src/component/swipe_input.dart';
import 'package:flame_gallery_slice/src/config/slice_config.dart';
import 'package:flame_gallery_slice/src/config/slice_item.dart';
import 'package:flame_gallery_slice/src/logic/launch_planner.dart';
import 'package:flame_gallery_slice/src/logic/slice_geometry.dart';
import 'package:flame_gallery_slice/src/logic/slice_rules.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum SliceEndCause { timeUp, outOfLives, bomb, quit }

final class SliceGame extends GalleryFlameGame {
  SliceGame({
    required this.config,
    required this.colors,
    required super.gameId,
    math.Random? random,
  }) : _random = random ?? math.Random(),
       _rules = SliceRules(maxLives: config.lives),
       _lives = ValueNotifier<int?>(config.lives),
       assert(config.items.isNotEmpty, 'At least one SliceItem is required'),
       _secondsLeft = ValueNotifier<int?>(_ceilSeconds(config.timeLimit)) {
    images = Images(prefix: '');
  }

  /// Item diameter as a fraction of the shorter screen side.
  static const _itemSizeFactor = 0.17;
  static const _halfPush = 160.0;
  static const _maxSpin = 4.0;
  static const _burstLifespan = 0.6;
  static const _burstGravityFactor = 2.4;
  static const _juiceCount = 14;
  static const _juiceSpeed = 260.0;
  static const _juiceMaxRadius = 6.0;
  static const _bombCount = 40;
  static const _bombSpeed = 420.0;
  static const _bombMaxRadius = 9.0;
  static const _comboFontSize = 34.0;
  static const _comboRise = 70.0;
  static const _comboDuration = 0.7;

  final SliceConfig config;
  final ColorScheme colors;
  final ValueNotifier<int?> _lives;
  final ValueNotifier<int?> _secondsLeft;

  ValueListenable<int?> get lives => _lives;
  ValueListenable<int?> get secondsLeft => _secondsLeft;

  final math.Random _random;
  final SliceRules _rules;
  late final LaunchPlanner _planner = LaunchPlanner(random: _random);
  late final ItemSpawner _spawner;
  late final BladeTrail _trail;
  late final TextPaint _comboPaint;
  final Map<SliceItem, Sprite> _sprites = {};
  Sprite? _bombSprite;
  double _timeLeft = 0;
  SliceEndCause? _endCause;
  Vector2? _lastSwipePoint;

  @override
  Color backgroundColor() => colors.surface;

  @override
  Future<void> onLoad() async {
    for (final item in config.items) {
      _sprites[item] = Sprite(await images.load(item.sprite.key));
    }
    final bomb = config.bomb;
    if (bomb != null) _bombSprite = Sprite(await images.load(bomb.key));
    final background = config.background;
    if (background != null) {
      await add(_Background(sprite: Sprite(await images.load(background.key))));
    }

    _spawner = ItemSpawner(difficulty: config.difficulty, random: _random);
    _comboPaint = TextPaint(
      style: TextStyle(
        color: colors.primary,
        fontSize: _comboFontSize,
        fontWeight: FontWeight.w800,
      ),
    );
    _trail = BladeTrail(
      color: colors.onSurface,
      glow: colors.primary.withValues(alpha: 0.7),
    )..priority = 10;
    await addAll([_spawner, _trail, SwipeInput()..priority = 20]);
    await super.onLoad();
  }

  @override
  void onRoundStart() {
    removeAll([
      ...children.whereType<SliceItemComponent>(),
      ...children.whereType<SlicedHalfComponent>(),
    ]);
    _rules.reset();
    _spawner.reset();
    _trail.clear();
    _endCause = null;
    _timeLeft = (config.timeLimit?.inMilliseconds ?? 0) / 1000;
    _lives.value = config.lives;
    _secondsLeft.value = _ceilSeconds(config.timeLimit);
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying || config.timeLimit == null) return;
    _timeLeft -= dt;
    final seconds = math.max(0, _timeLeft.ceil());
    if (seconds != _secondsLeft.value) _secondsLeft.value = seconds;
    if (_timeLeft <= 0) _end(SliceEndCause.timeUp);
  }

  @override
  Map<String, Object> collectStats() => {
    'sliced': _rules.sliced,
    'maxCombo': _rules.maxCombo,
    'endedBy': (_endCause ?? SliceEndCause.quit).name,
  };

  @internal
  void spawnWave(int count) {
    final bombSprite = _bombSprite;
    final bombIndex =
        bombSprite != null && _random.nextDouble() < config.bombChance
        ? _random.nextInt(count)
        : -1;
    for (var i = 0; i < count; i++) {
      if (i == bombIndex) {
        _spawn(item: null, sprite: bombSprite!, scale: 1);
      } else {
        final item = config.items[_random.nextInt(config.items.length)];
        _spawn(item: item, sprite: _sprites[item]!, scale: item.scale);
      }
    }
  }

  @internal
  void beginStroke(Vector2 point) {
    _lastSwipePoint = point.clone();
    _trail.addPoint(point, startsStroke: true);
  }

  @internal
  void swipe(Vector2 from, Vector2 to) {
    _lastSwipePoint = to.clone();
    _trail.addPoint(to);
    if (!isPlaying) return;
    final hits = children
        .whereType<SliceItemComponent>()
        .where(
          (c) =>
              !c.isSliced &&
              segmentHitsCircle(from, to, c.position, c.hitRadius),
        )
        .toList();
    final direction = to - from;
    for (final target in hits) {
      _slice(target, direction);
      if (!isPlaying) return;
    }
  }

  @internal
  void endStroke() {
    final bonus = _rules.endStroke();
    final at = _lastSwipePoint;
    if (bonus == 0 || at == null || !isPlaying) return;
    addScore(bonus);
    add(
      FloatingLabel(
        text: '×$bonus',
        position: at,
        paint: _comboPaint,
        rise: _comboRise,
        duration: _comboDuration,
      ),
    );
  }

  @internal
  void onItemMissed() {
    if (!isPlaying) return;
    final outOfLives = _rules.registerMiss();
    _lives.value = _rules.lives;
    if (outOfLives) _end(SliceEndCause.outOfLives);
  }

  void _spawn({
    required SliceItem? item,
    required Sprite sprite,
    required double scale,
  }) {
    final diameter = size.x < size.y
        ? size.x * _itemSizeFactor * scale
        : size.y * _itemSizeFactor * scale;
    final launch = _planner.plan(
      area: size,
      itemRadius: diameter / 2,
      speedFactor: config.difficulty.speedFactor,
    );
    add(
      SliceItemComponent(
        item: item,
        sprite: sprite,
        position: launch.position,
        velocity: launch.velocity,
        gravity: launch.gravity,
        diameter: diameter,
        spin: (_random.nextDouble() * 2 - 1) * _maxSpin,
      ),
    );
  }

  void _slice(SliceItemComponent target, Vector2 direction) {
    target
      ..isSliced = true
      ..removeFromParent();
    final item = target.item;
    if (item == null) {
      add(
        _burst(
          target.position,
          colors.error,
          count: _bombCount,
          speed: _bombSpeed,
          maxRadius: _bombMaxRadius,
        ),
      );
      _end(SliceEndCause.bomb);
      return;
    }
    addScore(_rules.registerSlice(item.points));
    addAll([
      ..._halvesOf(target, direction),
      _burst(
        target.position,
        item.juiceColor,
        count: _juiceCount,
        speed: _juiceSpeed,
        maxRadius: _juiceMaxRadius,
      ),
    ]);
  }

  ParticleSystemComponent _burst(
    Vector2 at,
    Color color, {
    required int count,
    required double speed,
    required double maxRadius,
  }) => GalleryBurst.at(
    position: at,
    color: color,
    random: _random,
    count: count,
    lifespan: _burstLifespan,
    speed: speed,
    maxRadius: maxRadius,
    gravity: speed * _burstGravityFactor,
  );

  /// Splits the sprite into left/right halves along the swipe direction.
  List<SlicedHalfComponent> _halvesOf(
    SliceItemComponent target,
    Vector2 direction,
  ) {
    final sprite = target.sprite!;
    final image = sprite.image;
    final half = Vector2(image.width / 2, image.height.toDouble());
    final cutAngle = math.atan2(direction.y, direction.x) + math.pi / 2;
    final push = Vector2(math.cos(cutAngle), math.sin(cutAngle))
      ..scale(_halfPush);
    final halfSize = Vector2(target.size.x / 2, target.size.y);

    SlicedHalfComponent build({required bool left}) => SlicedHalfComponent(
      sprite: Sprite(
        image,
        srcPosition: left ? Vector2.zero() : Vector2(half.x, 0),
        srcSize: half,
      ),
      position: target.position.clone(),
      size: halfSize,
      anchor: left ? Anchor.centerRight : Anchor.centerLeft,
      angle: cutAngle,
      velocity: target.velocity.clone()..addScaled(push, left ? -1 : 1),
      gravity: target.gravity,
      spin: target.spin * (left ? -1 : 1),
    );

    return [build(left: true), build(left: false)];
  }

  static int? _ceilSeconds(Duration? duration) => duration == null
      ? null
      : (duration.inMilliseconds / Duration.millisecondsPerSecond).ceil();

  void _end(SliceEndCause cause) {
    _endCause = cause;
    finish();
  }

  @override
  void onRemove() {
    _lives.dispose();
    _secondsLeft.dispose();
    super.onRemove();
  }
}

final class _Background extends SpriteComponent {
  _Background({required super.sprite}) : super(priority: -1);

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }
}
