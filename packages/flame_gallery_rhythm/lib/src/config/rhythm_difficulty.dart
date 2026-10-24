/// How long a note is visible before it reaches the hit line.
enum RhythmDifficulty {
  easy(approachSeconds: 2.2),
  normal(approachSeconds: 1.7),
  hard(approachSeconds: 1.3);

  RhythmDifficulty({required this.approachSeconds});

  final double approachSeconds;
}
