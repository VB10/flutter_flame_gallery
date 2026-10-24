import 'package:flutter/foundation.dart';

/// Every user facing text of the shared overlays. Games ship defaults,
/// host apps override with [copyWith].
@immutable
final class GameStrings {
  const GameStrings({
    required this.title,
    required this.instructions,
    required this.start,
    required this.resume,
    required this.playAgain,
    required this.close,
    required this.paused,
    required this.gameOver,
    required this.score,
    this.pause = 'Pause',
  });

  const GameStrings.en({required this.title, required this.instructions})
    : start = 'Start',
      resume = 'Resume',
      playAgain = 'Play again',
      close = 'Close',
      paused = 'Paused',
      gameOver = 'Game over',
      score = 'Score',
      pause = 'Pause';

  const GameStrings.tr({required this.title, required this.instructions})
    : start = 'Başla',
      resume = 'Devam et',
      playAgain = 'Tekrar oyna',
      close = 'Kapat',
      paused = 'Duraklatıldı',
      gameOver = 'Oyun bitti',
      score = 'Skor',
      pause = 'Duraklat';

  final String title;
  final String instructions;
  final String start;
  final String resume;
  final String playAgain;
  final String close;
  final String paused;
  final String gameOver;
  final String score;

  /// Accessibility label of the HUD pause button.
  final String pause;

  GameStrings copyWith({
    String? title,
    String? instructions,
    String? start,
    String? resume,
    String? playAgain,
    String? close,
    String? paused,
    String? gameOver,
    String? score,
    String? pause,
  }) => GameStrings(
    title: title ?? this.title,
    instructions: instructions ?? this.instructions,
    start: start ?? this.start,
    resume: resume ?? this.resume,
    playAgain: playAgain ?? this.playAgain,
    close: close ?? this.close,
    paused: paused ?? this.paused,
    gameOver: gameOver ?? this.gameOver,
    score: score ?? this.score,
    pause: pause ?? this.pause,
  );
}
