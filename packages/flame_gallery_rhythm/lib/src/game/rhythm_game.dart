import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_rhythm/src/audio/rhythm_audio.dart';
import 'package:flame_gallery_rhythm/src/audio/rhythm_audio_sync.dart';
import 'package:flame_gallery_rhythm/src/component/lane_board.dart';
import 'package:flame_gallery_rhythm/src/component/note_component.dart';
import 'package:flame_gallery_rhythm/src/config/rhythm_config.dart';
import 'package:flame_gallery_rhythm/src/config/rhythm_labels.dart';
import 'package:flame_gallery_rhythm/src/game/rhythm_layout.dart';
import 'package:flame_gallery_rhythm/src/game/rhythm_stat_keys.dart';
import 'package:flame_gallery_rhythm/src/logic/note_chart.dart';
import 'package:flame_gallery_rhythm/src/logic/rhythm_judge.dart';
import 'package:flame_gallery_rhythm/src/logic/rhythm_score.dart';
import 'package:flame_gallery_rhythm/src/logic/song_clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

enum RhythmEndCause { songEnd, tooManyMisses, quit }

final class RhythmGame extends GalleryFlameGame
    with GameEndCause<RhythmEndCause> {
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
       _clock = SongClock(
         hasAudio: audio != null,
         latency: config.audioLatency.asSeconds,
       ),
       _missesLeft = ValueNotifier<int?>(config.missLimit) {
    _audioSync = RhythmAudioSync(audio: audio, phase: phase);
  }

  final RhythmConfig config;
  final ColorScheme colors;

  /// Optional music. Its position, when known, drives the song clock.
  final RhythmAudio? audio;
  final RhythmLabels labels;

  static const _labelFontSize = 22.0;
  static const _labelRise = 48.0;
  static const _labelDuration = 0.5;
  static const _burstLifespan = 0.35;
  static const _burstSpeed = 220.0;
  static const _burstMaxRadius = 4.5;

  final NoteChart _chart;
  final SongClock _clock;
  final RhythmScore _score = RhythmScore();
  final math.Random _effectsRandom = math.Random();
  final ValueNotifier<int> _combo = ValueNotifier<int>(0);
  final ValueNotifier<int> _accuracy = ValueNotifier<int>(
    RhythmScore.fullAccuracy,
  );
  final ValueNotifier<int?> _missesLeft;
  late final RhythmAudioSync _audioSync;

  /// Notes on screen that can still be hit, by chart index.
  final Map<int, NoteComponent> _openNotes = {};
  late final List<Sprite> _sprites;
  late final List<Color> _lanePalette = [
    colors.primary,
    colors.secondary,
    colors.tertiary,
    colors.error,
  ];
  late final Map<Judgement, TextPaint> _labelPaints;
  late final LaneBoard _board;
  late RhythmLayout _layout = RhythmLayout(size: size, lanes: config.lanes);

  /// Chart index of the next note to spawn.
  int _nextSpawn = 0;

  ValueListenable<int> get combo => _combo;
  ValueListenable<int> get accuracy => _accuracy;
  ValueListenable<int?> get missesLeft => _missesLeft;
  @internal
  RhythmLayout get layout => _layout;

  /// Seconds into the song as the player hears it: the audio position minus
  /// [RhythmConfig.audioLatency] when the player reports one, otherwise the
  /// game's own clock.
  double get songTime => _clock.at(audio?.position?.asSeconds);

  @visibleForTesting
  int countOf(Judgement judgement) => _score.countOf(judgement);

  @override
  Color backgroundColor() => resolveBackground(colors.surface);

  @override
  Future<void> onLoad() async {
    _sprites = await loadSprites(config.noteSprites);
    await addBackground(config.background);
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
    _openNotes.clear();
    _chart.reset();
    _score.reset();
    _clock.reset();
    _nextSpawn = 0;
    _combo.value = 0;
    _accuracy.value = _score.accuracy;
    _missesLeft.value = config.missLimit;
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (!isPlaying) return;
    _clock.advance(dt, audioPosition: audio?.position?.asSeconds);
    final now = _clock.time;
    _spawnUpTo(now);
    for (final index in _chart.expire(now)) {
      _onMiss(index);
      if (!isPlaying) return;
    }
    if (now >= config.song.length.asSeconds) {
      finishWith(RhythmEndCause.songEnd);
    }
  }

  @override
  Map<String, Object> collectStats() => {
    RhythmStatKeys.perfect: _score.countOf(Judgement.perfect),
    RhythmStatKeys.great: _score.countOf(Judgement.great),
    RhythmStatKeys.good: _score.countOf(Judgement.good),
    RhythmStatKeys.miss: _score.countOf(Judgement.miss),
    RhythmStatKeys.maxCombo: _score.maxCombo,
    RhythmStatKeys.accuracy: _score.accuracy,
    ...super.collectStats(),
  };

  /// A tap in [lane]: judged against the closest open note of that lane.
  @internal
  void tapLane(int lane) {
    if (!isPlaying) return;
    _board.flashLane(lane);
    final hit = _chart.tap(lane, songTime);
    if (hit == null) return;
    sounds.play(GameSoundCue.noteHit);
    addScore(_score.register(hit.judgement));
    _syncStats();
    _openNotes.remove(hit.index)?.removeFromParent();
    final at = _hitPoint(lane);
    addAll([
      GalleryBurst.at(
        position: at,
        color: _lanePalette[lane % _lanePalette.length],
        random: _effectsRandom,
        lifespan: _burstLifespan,
        speed: _burstSpeed,
        maxRadius: _burstMaxRadius,
      ),
      _label(hit.judgement, at),
    ]);
  }

  /// Adds every note that is due to appear by [now].
  void _spawnUpTo(double now) {
    final lead = config.difficulty.approachSeconds;
    final notes = _chart.notes;
    while (_nextSpawn < notes.length && notes[_nextSpawn].time - lead <= now) {
      final note = notes[_nextSpawn];
      final component = NoteComponent(
        index: _nextSpawn,
        time: note.time,
        lane: note.lane,
        sprite: _sprites[note.lane % _sprites.length],
      );
      _openNotes[_nextSpawn] = component;
      add(component);
      _nextSpawn++;
    }
  }

  void _onMiss(int index) {
    sounds.play(GameSoundCue.noteMiss);
    _score.register(Judgement.miss);
    _syncStats();
    _openNotes.remove(index)?.markMissed();
    add(_label(Judgement.miss, _hitPoint(_chart.notes[index].lane)));
    final limit = config.missLimit;
    if (limit == null) return;
    final left = math.max(0, limit - _score.countOf(Judgement.miss));
    _missesLeft.value = left;
    if (left == 0) finishWith(RhythmEndCause.tooManyMisses);
  }

  Vector2 _hitPoint(int lane) =>
      Vector2(_layout.laneCenterX(lane), _layout.hitY);

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

  @override
  void onRemove() {
    _audioSync.dispose();
    _combo.dispose();
    _accuracy.dispose();
    _missesLeft.dispose();
    super.onRemove();
  }
}
