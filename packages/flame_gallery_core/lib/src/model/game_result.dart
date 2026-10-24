import 'package:flutter/foundation.dart';

enum GameEndReason {
  /// The game reached its own end condition (time up, out of lives...).
  completed,

  /// The player closed the game before it ended.
  quit,
}

@immutable
final class GameResult {
  const GameResult({
    required this.gameId,
    required this.score,
    required this.reason,
    required this.playTime,
    this.stats = const {},
  });

  final String gameId;
  final int score;
  final GameEndReason reason;
  final Duration playTime;

  /// Game specific numbers, e.g. `{'sliced': 42, 'maxCombo': 5}`.
  final Map<String, Object> stats;

  bool get isCompleted => reason == GameEndReason.completed;

  /// Flat JSON, suitable for a platform channel or analytics payload.
  Map<String, Object> toJson() => {
    'gameId': gameId,
    'score': score,
    'reason': reason.name,
    'playTimeMs': playTime.inMilliseconds,
    'stats': stats,
  };

  @override
  String toString() => 'GameResult(${toJson()})';
}
