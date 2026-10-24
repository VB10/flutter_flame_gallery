import 'package:flutter/foundation.dart';

/// Texts of the floating timing judgements.
@immutable
final class RhythmLabels {
  const RhythmLabels({
    required this.perfect,
    required this.great,
    required this.good,
    required this.miss,
  });

  static const en = RhythmLabels(
    perfect: 'Perfect',
    great: 'Great',
    good: 'Good',
    miss: 'Miss',
  );

  static const tr = RhythmLabels(
    perfect: 'Mükemmel',
    great: 'Harika',
    good: 'İyi',
    miss: 'Kaçtı',
  );

  final String perfect;
  final String great;
  final String good;
  final String miss;
}
