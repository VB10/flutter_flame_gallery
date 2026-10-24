import 'package:flame_gallery_rhythm/src/logic/rhythm_judge.dart';

/// A note placed on the song timeline.
final class ChartNote {
  ChartNote({required this.time, required this.lane});

  /// Seconds from the song start.
  final double time;
  final int lane;
  Judgement? judgement;

  bool get isJudged => judgement != null;
}

/// Which notes are still open, and judging taps and misses against them.
final class NoteChart {
  NoteChart(Iterable<ChartNote> notes)
    : notes = List.unmodifiable(
        notes.toList()..sort((a, b) => a.time.compareTo(b.time)),
      );

  /// Sorted by time.
  final List<ChartNote> notes;

  bool get allJudged => notes.every((note) => note.isJudged);

  void reset() {
    for (final note in notes) {
      note.judgement = null;
    }
  }

  /// Judges a tap in [lane] at [now] against the closest open note of that
  /// lane. Returns `null` when no note is within the good window.
  ({int index, Judgement judgement})? tap(int lane, double now) {
    int? best;
    var bestDistance = double.infinity;
    for (var i = 0; i < notes.length; i++) {
      final note = notes[i];
      if (note.isJudged || note.lane != lane) continue;
      final distance = (note.time - now).abs();
      if (distance < bestDistance) {
        best = i;
        bestDistance = distance;
      }
      if (note.time > now + RhythmJudge.goodWindow) break;
    }
    if (best == null) return null;
    final judgement = RhythmJudge.judge(notes[best].time - now);
    if (judgement == null) return null;
    notes[best].judgement = judgement;
    return (index: best, judgement: judgement);
  }

  /// Marks every open note whose good window has passed as a miss and
  /// returns their indices.
  List<int> expire(double now) {
    final missed = <int>[];
    for (var i = 0; i < notes.length; i++) {
      final note = notes[i];
      if (note.time + RhythmJudge.goodWindow >= now) break;
      if (note.isJudged) continue;
      note.judgement = Judgement.miss;
      missed.add(i);
    }
    return missed;
  }
}
