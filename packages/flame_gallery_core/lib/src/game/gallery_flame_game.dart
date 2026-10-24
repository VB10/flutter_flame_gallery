import 'dart:async';
import 'dart:math' as math;

import 'package:flame/flame.dart';
import 'package:flame/game.dart';
import 'package:flame_gallery_core/src/game/game_overlays.dart';
import 'package:flame_gallery_core/src/game/game_phase.dart';
import 'package:flame_gallery_core/src/model/game_event.dart';
import 'package:flame_gallery_core/src/model/game_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Base class every gallery game extends.
///
/// Owns the phase machine (ready → playing ⇄ paused → over), the score, the
/// shared overlays and the event stream. Subclasses only implement gameplay:
/// reset their world in [onRoundStart], call [addScore] and [finish].
abstract base class GalleryFlameGame extends FlameGame {
  GalleryFlameGame({required this.gameId});

  final String gameId;

  /// How long the world keeps running behind the game over panel (so bursts
  /// and falling halves finish) before the engine is paused to save battery.
  static const _overRunoutSeconds = 0.8;

  final ValueNotifier<int> _score = ValueNotifier<int>(0);
  final ValueNotifier<GamePhase> _phase = ValueNotifier<GamePhase>(
    GamePhase.ready,
  );

  /// Synchronous so events raised while the game is being removed (e.g. the
  /// quit result in [onRemove]) still reach the host before it unsubscribes.
  final StreamController<GameEvent> _events =
      StreamController<GameEvent>.broadcast(sync: true);
  double _playSeconds = 0;
  double _runoutLeft = 0;
  GameResult? _result;

  ValueListenable<int> get score => _score;
  ValueListenable<GamePhase> get phase => _phase;
  Stream<GameEvent> get events => _events.stream;
  GameResult? get result => _result;
  bool get isPlaying => _phase.value == GamePhase.playing;
  Duration get playTime => Duration(
    microseconds: (_playSeconds * Duration.microsecondsPerSecond).round(),
  );

  /// Clears the world for a fresh round. Called on every [start].
  @protected
  void onRoundStart();

  /// Extra numbers attached to the [GameResult].
  @protected
  Map<String, Object> collectStats() => const {};

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _syncOverlays();
  }

  void start() {
    if (_phase.value case GamePhase.playing || GamePhase.paused) return;
    if (paused) resumeEngine();
    _playSeconds = 0;
    _result = null;
    _score.value = 0;
    onRoundStart();
    _setPhase(GamePhase.playing);
    _emit(GameStarted(gameId: gameId));
  }

  void pause() {
    if (!isPlaying) return;
    pauseEngine();
    _setPhase(GamePhase.paused);
    _emit(GamePaused(gameId: gameId));
  }

  void resume() {
    if (_phase.value != GamePhase.paused) return;
    resumeEngine();
    _setPhase(GamePhase.playing);
    _emit(GameResumed(gameId: gameId));
  }

  /// Ends the round and shows the game over panel.
  /// Returns the result, or the existing one if already over.
  GameResult? finish({GameEndReason reason = GameEndReason.completed}) =>
      _end(reason, showGameOver: true);

  /// Ends the round because the player is leaving; no game over panel.
  GameResult? quit() => _end(GameEndReason.quit, showGameOver: false);

  void addScore(int points) {
    if (!isPlaying || points == 0) return;
    _score.value = math.max(0, _score.value + points);
    _emit(GameScoreChanged(gameId: gameId, score: _score.value));
  }

  @override
  void update(double dt) {
    if (isPlaying) _playSeconds += dt;
    super.update(dt);
    if (_phase.value != GamePhase.over || _runoutLeft <= 0) return;
    _runoutLeft -= dt;
    if (_runoutLeft <= 0) pauseEngine();
  }

  @override
  void lifecycleStateChange(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) pause();
    super.lifecycleStateChange(state);
  }

  @override
  void onRemove() {
    quit();
    unawaited(_events.close());
    _score.dispose();
    _phase.dispose();
    super.onRemove();
    // Flame only clears caches in dispose(), which GameWidget never calls.
    // Games own a private Images cache, so free its decoded images here.
    if (!identical(images, Flame.images)) images.clearCache();
  }

  GameResult? _end(GameEndReason reason, {required bool showGameOver}) {
    if (_phase.value case GamePhase.ready || GamePhase.over) return _result;
    if (paused) resumeEngine();
    final result = GameResult(
      gameId: gameId,
      score: _score.value,
      reason: reason,
      playTime: playTime,
      stats: collectStats(),
    );
    _result = result;
    _phase.value = GamePhase.over;
    _runoutLeft = _overRunoutSeconds;
    if (showGameOver) _syncOverlays();
    _emit(GameFinished(result: result));
    return result;
  }

  void _setPhase(GamePhase next) {
    _phase.value = next;
    _syncOverlays();
  }

  void _syncOverlays() {
    final wanted = GameOverlays.forPhase(_phase.value);
    overlays
      ..removeAll(overlays.activeOverlays.where((o) => !wanted.contains(o)))
      ..addAll(wanted);
  }

  void _emit(GameEvent event) {
    if (!_events.isClosed) _events.add(event);
  }
}
