import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_slice/src/component/blade_trail.dart';
import 'package:flame_gallery_slice/src/component/item_spawner.dart';
import 'package:flame_gallery_slice/src/component/slice_item_component.dart';
import 'package:flame_gallery_slice/src/component/sliced_half_component.dart';
import 'package:flame_gallery_slice/src/component/swipe_input.dart';
import 'package:flame_gallery_slice/src/config/slice_config.dart';
import 'package:flame_gallery_slice/src/config/slice_item.dart';
import 'package:flame_gallery_slice/src/game/slice_stat_keys.dart';
import 'package:flame_gallery_slice/src/logic/launch_planner.dart';
import 'package:flame_gallery_slice/src/logic/slice_geometry.dart';
import 'package:flame_gallery_slice/src/logic/slice_rules.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum SliceEndCause { timeUp, outOfLives, bomb, quit }

typedef _BurstSpec = ({int count, double speed, double maxRadius});

final class SliceGame extends GalleryFlameGame
    with GameEndCause<SliceEndCause> {
  SliceGame({
    required this.config,
    required this.colors,
    required super.gameId,
    this.comboTemplate = '×{value}',
    math.Random? random,
  }) : assert(config.items.isNotEmpty, 'At least one SliceItem is required'),
       _random = random ?? math.Random(),
       _rules = SliceRules(maxLives: config.lives),
       _lives = ValueNotifier<int?>(config.lives),
       _countdown = RoundCountdown(config.timeLimit);

  /// Item diameter as a fraction of the shorter screen side.
  static const _itemSizeFactor = 0.17;
  static const _maxSpin = 4.0;
  static const _trailPriority = 10;
  static const _inputPriority = 20;
  static const _trailGlowAlpha = 0.7;
  static const _comboFontSize = 34.0;
  static const _comboRise = 70.0;
  static const _comboDuration = 0.7;
  static const _burstLifespan = 0.6;
  static const _burstGravityFactor = 2.4;
  static const _BurstSpec _juice = (count: 14, speed: 260, maxRadius: 6);
  static const _BurstSpec _explosion = (count: 40, speed: 420, maxRadius: 9);

  final SliceConfig config;
  final ColorScheme colors;

  /// Bonus label text; `{value}` is the bonus points.
  final String comboTemplate;

  /// Drives spawns only, so a seeded game throws the same waves however the
  /// player slices. Particles use [_effectsRandom].
  final math.Random _random;
  final math.Random _effectsRandom = math.Random();
  final SliceRules _rules;
  final ValueNotifier<int?> _lives;
  final RoundCountdown _countdown;
  late final LaunchPlanner _planner = LaunchPlanner(random: _random);
  late final Map<SliceItem, Sprite> _sprites;
  late final ItemSpawner _spawner;
  late final BladeTrail _trail;
  late final TextPaint _comboPaint;
  Sprite? _bombSprite;
  Vector2? _lastSwipePoint;

  ValueListenable<int?> get lives => _lives;
  ValueListenable<int?> get secondsLeft => _countdown.secondsLeft;

  @override
  Color backgroundColor() => resolveBackground(colors.surface);

  @override
  Future<void> onLoad() async {
    final sprites = await loadSprites(config.items.map((item) => item.sprite));
    _sprites = Map.fromIterables(config.items, sprites);
    final bomb = config.bomb;
    if (bomb != null) _bombSprite = await loadSprite(bomb.key);
    await addBackground(config.background);

    _spawner = ItemSpawner(difficulty: config.difficulty, random: _random);
    _trail = BladeTrail(
      color: colors.onSurface,
      glow: colors.primary.withValues(alpha: _trailGlowAlpha),
    )..priority = _trailPriority;
    _comboPaint = TextPaint(
      style: TextStyle(
        color: colors.primary,
        fontSize: _comboFontSize,
        fontWeight: FontWeight.w800,
      ),
    );
    await addAll([_spawner, _trail, SwipeInput()..priority = _inputPriority]);
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
    _lives.value = config.lives;
    _countdown.reset();
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (isPlaying && _countdown.tick(dt)) finishWith(SliceEndCause.timeUp);
  }

  @override
  Map<String, Object> collectStats() => {
    SliceStatKeys.sliced: _rules.sliced,
    SliceStatKeys.maxCombo: _rules.maxCombo,
    ...super.collectStats(),
  };

  /// Throws [count] items; at most one of them is a bomb.
  @internal
  void spawnWave(int count) {
    final bomb = _bombSprite;
    final bombAt = bomb != null && _random.nextDouble() < config.bombChance
        ? _random.nextInt(count)
        : null;
    for (var i = 0; i < count; i++) {
      if (bomb != null && i == bombAt) {
        _spawn(item: null, sprite: bomb, scale: 1);
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

  /// One finger move: slices every item the segment [from]→[to] crosses.
  @internal
  void swipe(Vector2 from, Vector2 to) {
    _lastSwipePoint = to.clone();
    _trail.addPoint(to);
    if (!isPlaying) return;
    final hits = [
      for (final item in children.whereType<SliceItemComponent>())
        if (!item.isSliced &&
            segmentHitsCircle(from, to, item.position, item.hitRadius))
          item,
    ];
    final direction = to - from;
    for (final target in hits) {
      _slice(target, direction);
      if (!isPlaying) return;
    }
  }

  /// Finger lifted: pays the combo bonus for the stroke, if any.
  @internal
  void endStroke() {
    final bonus = _rules.endStroke();
    final at = _lastSwipePoint;
    if (bonus == 0 || at == null || !isPlaying) return;
    addScore(bonus);
    add(
      FloatingLabel(
        text: GameStrings.fill(comboTemplate, bonus),
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
    if (outOfLives) finishWith(SliceEndCause.outOfLives);
  }

  void _spawn({
    required SliceItem? item,
    required Sprite sprite,
    required double scale,
  }) {
    final diameter = math.min(size.x, size.y) * _itemSizeFactor * scale;
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
      _explode(target.position);
      return;
    }
    sounds.play(GameSoundCue.slice);
    addScore(_rules.registerSlice(item.points));
    addAll([
      ...SlicedHalfComponent.split(target, direction),
      _burst(target.position, item.juiceColor, _juice),
    ]);
  }

  void _explode(Vector2 at) {
    sounds.play(GameSoundCue.bomb);
    add(_burst(at, colors.error, _explosion));
    finishWith(SliceEndCause.bomb);
  }

  ParticleSystemComponent _burst(Vector2 at, Color color, _BurstSpec spec) =>
      GalleryBurst.at(
        position: at,
        color: color,
        random: _effectsRandom,
        count: spec.count,
        lifespan: _burstLifespan,
        speed: spec.speed,
        maxRadius: spec.maxRadius,
        gravity: spec.speed * _burstGravityFactor,
      );

  @override
  void onRemove() {
    _lives.dispose();
    _countdown.dispose();
    super.onRemove();
  }
}
