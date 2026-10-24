import 'dart:async';
import 'dart:math' as math;

import 'package:flame/cache.dart';
import 'package:flame/components.dart';
import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_rhythm/src/audio/rhythm_audio.dart';
import 'package:flame_gallery_rhythm/src/component/lane_board.dart';
import 'package:flame_gallery_rhythm/src/component/note_component.dart';
import 'package:flame_gallery_rhythm/src/config/rhythm_config.dart';
import 'package:flame_gallery_rhythm/src/config/rhythm_labels.dart';
import 'package:flame_gallery_rhythm/src/game/rhythm_layout.dart';
import 'package:flame_gallery_rhythm/src/logic/note_chart.dart';
import 'package:flame_gallery_rhythm/src/logic/rhythm_judge.dart';
import 'package:flame_gallery_rhythm/src/logic/rhythm_score.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum RhythmEndCause { songEnd, tooManyMisses, quit }

final class RhythmGame extends GalleryFlameGame {
  RhythmGame({
    required this.config,
    required this.colors,
    required super.gameId,
    this.audio,
    this.labels = RhythmLabels.en,
  }) : assert(
         config.song.notes.every((n) => n.lane >= 0 && n.lane < config.lanes),
         'Every note lane must be below RhythmConfig.lanes',
       ),
       assert(config.noteSprites.isNotEmpty, 'noteSprites must not be empty'),
       _chart = NoteChart([
         for (final note in config.song.notes)
           ChartNote(time: config.song.timeOf(note.beat), lane: note.lane),
       ]),
       _missesLeft = ValueNotifier<int?>(config.missLimit) {
    images = Images(prefix: '');
    _lastPhase = phase.value;
    phase.addListener(_onPhaseChanged);
  }

  final RhythmConfig config;
  final ColorScheme colors;

  /// Optional music. Its position, when known, drives the song clock.
  final RhythmAudio? audio;
  final RhythmLabels labels;

  /// How long the clock waits for the player's first position report before
  /// running on its own, so notes do not jump when the music kicks in.
  static const _audioStartTimeout = 1.0;
  static const _labelFontSize = 22.0;
  static const _labelRise = 48.0;
  static const _labelDuration = 0.5;
  static const _burstLifespan = 0.35;
  static const _burstSpeed = 220.0;
  static const _burstMaxRadius = 4.5;

  final NoteChart _chart;
  final RhythmScore _score = RhythmScore();
  final math.Random _effectsRandom = math.Random();
  final ValueNotifier<int> _combo = ValueNotifier<int>(0);
  final ValueNotifier<int> _accuracy = ValueNotifier<int>(
    RhythmScore.fullAccuracy,
  );
  final ValueNotifier<int?> _missesLeft;
  final List<Sprite> _sprites = [];
  late RhythmLayout _layout = RhythmLayout(size: size, lanes: config.lanes);
  late final LaneBoard _board;
  double _clock = 0;
  double _audioWait = 0;
  bool _musicReported = false;
  late final Map<Judgement, TextPaint> _labelPaints;
  int _nextSpawn = 0;
  late GamePhase _lastPhase;
  bool _audioActive = false;
  RhythmEndCause? _endCause;

  ValueListenable<int> get combo => _combo;
  ValueListenable<int> get accuracy => _accuracy;
  ValueListenable<int?> get missesLeft => _missesLeft;
  @internal
  RhythmLayout get layout => _layout;

  /// Seconds into the song as the player hears it: the audio position minus
  /// [RhythmConfig.audioLatency] when the player reports one, otherwise the
  /// game's own clock.
  double get songTime {
    final position = audio?.position;
    return position == null
        ? _clock
        : _seconds(position) - _seconds(config.audioLatency);
  }

  @visibleForTesting
  int countOf(Judgement judgement) => _score.countOf(judgement);

  @override
  Color backgroundColor() => colors.surface;

  @override
  Future<void> onLoad() async {
    for (final asset in config.noteSprites) {
      _sprites.add(Sprite(await images.load(asset.key)));
    }
    final background = config.background;
    if (background != null) {
      await add(_Background(sprite: Sprite(await images.load(background.key))));
    }
    _board = LaneBoard(
      lane: colors.surfaceContainer,
      separator: colors.outlineVariant,
      hitLine: colors.primary,
      flash: colors.primary,
    );
    await add(_board);
    _labelPaints = {
      for (final judgement in Judgement.values)
        judgement: TextPaint(
          style: TextStyle(
            color: judgement.isHit ? colors.primary : colors.error,
            fontSize: _labelFontSize,
            fontWeight: FontWeight.w800,
          ),
        ),
    };
    await super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _layout = RhythmLayout(size: size.clone(), lanes: config.lanes);
  }

  @override
  void onRoundStart() {
    removeAll(children.whereType<NoteComponent>());
    _chart.reset();
    _score.reset();
    _clock = 0;
    _audioWait = 0;
    _musicReported = false;
    _nextSpawn = 0;
    _endCause = null;
    _combo.value = 0;
    _accuracy.value = _score.accuracy;
    _missesLeft.value = config.missLimit;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying) return;
    _advanceClock(dt);
    final now = songTime;
    _spawnUpTo(now);
    for (final index in _chart.expire(now)) {
      _onMiss(index);
      if (!isPlaying) return;
    }
    if (now >= _seconds(config.song.length)) _end(RhythmEndCause.songEnd);
  }

  @override
  Map<String, Object> collectStats() => {
    'perfect': _score.countOf(Judgement.perfect),
    'great': _score.countOf(Judgement.great),
    'good': _score.countOf(Judgement.good),
    'miss': _score.countOf(Judgement.miss),
    'maxCombo': _score.maxCombo,
    'accuracy': _score.accuracy,
    'endedBy': (_endCause ?? RhythmEndCause.quit).name,
  };

  /// A tap in [lane]: judged against the closest open note of that lane.
  @internal
  void tapLane(int lane) {
    if (!isPlaying) return;
    _board.flashLane(lane);
    final hit = _chart.tap(lane, songTime);
    if (hit == null) return;
    addScore(_score.register(hit.judgement));
    _syncStats();
    final note = children
        .whereType<NoteComponent>()
        .where((c) => c.index == hit.index)
        .firstOrNull;
    final at = Vector2(_layout.laneCenterX(lane), _layout.hitY);
    note?.removeFromParent();
    addAll([
      GalleryBurst.at(
        position: at,
        color: _laneColor(lane),
        random: _effectsRandom,
        lifespan: _burstLifespan,
        speed: _burstSpeed,
        maxRadius: _burstMaxRadius,
      ),
      _label(hit.judgement, at),
    ]);
  }

  void _spawnUpTo(double now) {
    final lead = config.difficulty.approachSeconds;
    final notes = _chart.notes;
    while (_nextSpawn < notes.length && notes[_nextSpawn].time - lead <= now) {
      final note = notes[_nextSpawn];
      add(
        NoteComponent(
          index: _nextSpawn,
          time: note.time,
          lane: note.lane,
          sprite: _sprites[note.lane % _sprites.length],
        ),
      );
      _nextSpawn++;
    }
  }

  void _onMiss(int index) {
    _score.register(Judgement.miss);
    _syncStats();
    final note = _chart.notes[index];
    children
        .whereType<NoteComponent>()
        .where((c) => c.index == index)
        .firstOrNull
        ?.markMissed();
    add(
      _label(
        Judgement.miss,
        Vector2(_layout.laneCenterX(note.lane), _layout.hitY),
      ),
    );
    final limit = config.missLimit;
    if (limit == null) return;
    final left = math.max(0, limit - _score.countOf(Judgement.miss));
    _missesLeft.value = left;
    if (left == 0) _end(RhythmEndCause.tooManyMisses);
  }

  /// Follows the music whenever it reports a position, so the clock never
  /// drifts from it; runs on its own only without audio or when the player
  /// stops reporting. At start it waits briefly for the first report.
  void _advanceClock(double dt) {
    final audio = this.audio;
    final position = audio?.position;
    if (position != null) {
      _musicReported = true;
      _clock = _seconds(position) - _seconds(config.audioLatency);
    } else if (audio != null &&
        !_musicReported &&
        _audioWait < _audioStartTimeout) {
      _audioWait += dt;
    } else {
      _clock += dt;
    }
  }

  FloatingLabel _label(Judgement judgement, Vector2 at) => FloatingLabel(
    text: switch (judgement) {
      Judgement.perfect => labels.perfect,
      Judgement.great => labels.great,
      Judgement.good => labels.good,
      Judgement.miss => labels.miss,
    },
    position: at,
    paint: _labelPaints[judgement]!,
    rise: _labelRise,
    duration: _labelDuration,
  );

  void _syncStats() {
    _combo.value = _score.combo;
    _accuracy.value = _score.accuracy;
  }

  Color _laneColor(int lane) {
    final palette = [
      colors.primary,
      colors.secondary,
      colors.tertiary,
      colors.error,
    ];
    return palette[lane % palette.length];
  }

  void _end(RhythmEndCause cause) {
    _endCause = cause;
    finish();
  }

  void _onPhaseChanged() {
    final previous = _lastPhase;
    final next = phase.value;
    _lastPhase = next;
    switch ((previous, next)) {
      case (GamePhase.ready || GamePhase.over, GamePhase.playing):
        _audioActive = true;
        _callAudio((a) => a.start());
      case (GamePhase.playing, GamePhase.paused):
        _callAudio((a) => a.pause());
      case (GamePhase.paused, GamePhase.playing):
        _callAudio((a) => a.resume());
      case (_, GamePhase.over):
        _stopAudio();
      default:
        break;
    }
  }

  void _stopAudio() {
    if (!_audioActive) return;
    _audioActive = false;
    _callAudio((a) => a.stop());
  }

  /// Fire-and-forget; a failing player must never break the game loop.
  void _callAudio(Future<void> Function(RhythmAudio audio) call) {
    final audio = this.audio;
    if (audio == null) return;
    try {
      unawaited(call(audio).catchError((Object _) {}));
    } on Object catch (_) {
      // Synchronous throw from the player; ignored on purpose.
    }
  }

  static double _seconds(Duration duration) =>
      duration.inMicroseconds / Duration.microsecondsPerSecond;

  @override
  void onRemove() {
    phase.removeListener(_onPhaseChanged);
    _stopAudio();
    _combo.dispose();
    _accuracy.dispose();
    _missesLeft.dispose();
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
