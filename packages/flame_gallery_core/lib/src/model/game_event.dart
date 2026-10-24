import 'package:flame_gallery_core/src/model/game_result.dart';

/// Lifecycle events a game reports to the host app.
sealed class GameEvent {
  const GameEvent({required this.gameId});

  final String gameId;
}

final class GameStarted extends GameEvent {
  const GameStarted({required super.gameId});

  @override
  String toString() => 'GameStarted($gameId)';
}

final class GameScoreChanged extends GameEvent {
  const GameScoreChanged({required super.gameId, required this.score});

  final int score;

  @override
  String toString() => 'GameScoreChanged($gameId, $score)';
}

final class GamePaused extends GameEvent {
  const GamePaused({required super.gameId});

  @override
  String toString() => 'GamePaused($gameId)';
}

final class GameResumed extends GameEvent {
  const GameResumed({required super.gameId});

  @override
  String toString() => 'GameResumed($gameId)';
}

final class GameFinished extends GameEvent {
  GameFinished({required this.result}) : super(gameId: result.gameId);

  final GameResult result;

  @override
  String toString() => 'GameFinished($result)';
}
