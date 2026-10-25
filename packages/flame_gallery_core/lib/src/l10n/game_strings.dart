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
    this.combo = '×{value}',
    this.distance = '{value} m',
    this.accuracy = '{value}%',
  });

  const GameStrings.en({required this.title, required this.instructions})
    : start = 'Start',
      resume = 'Resume',
      playAgain = 'Play again',
      close = 'Close',
      paused = 'Paused',
      gameOver = 'Game over',
      score = 'Score',
      pause = 'Pause',
      combo = '×{value}',
      distance = '{value} m',
      accuracy = '{value}%';

  const GameStrings.tr({required this.title, required this.instructions})
    : start = 'Başla',
      resume = 'Devam et',
      playAgain = 'Tekrar oyna',
      close = 'Kapat',
      paused = 'Duraklatıldı',
      gameOver = 'Oyun bitti',
      score = 'Skor',
      pause = 'Duraklat',
      combo = '×{value}',
      distance = '{value} m',
      accuracy = '%{value}';

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

  /// Templates for the in-game value texts. `{value}` is replaced by the
  /// number: combo / bonus labels, runner distance, rhythm accuracy.
  final String combo;
  final String distance;
  final String accuracy;

  /// Fills the `{value}` placeholder of [template].
  static String fill(String template, Object value) =>
      template.replaceAll('{value}', '$value');

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
    String? combo,
    String? distance,
    String? accuracy,
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
    combo: combo ?? this.combo,
    distance: distance ?? this.distance,
    accuracy: accuracy ?? this.accuracy,
  );
}
