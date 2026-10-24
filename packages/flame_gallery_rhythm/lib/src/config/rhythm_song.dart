import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// One note: which lane, on which beat (whole or fractional).
@immutable
final class RhythmNote {
  const RhythmNote({required this.beat, required this.lane});

  final double beat;
  final int lane;

  @override
  bool operator ==(Object other) =>
      other is RhythmNote && other.beat == beat && other.lane == lane;

  @override
  int get hashCode => Object.hash(beat, lane);
}

/// A chart: tempo, lead-in silence and the notes to hit.
@immutable
final class RhythmSong {
  const RhythmSong({
    required this.bpm,
    required this.leadIn,
    required this.beats,
    required this.notes,
  });

  /// Deterministic random chart: one note per beat, some off-beat eighths and
  /// occasional two-lane chords.
  factory RhythmSong.generated({
    double bpm = 120,
    int beats = 64,
    int lanes = 4,
    int seed = 0,
    Duration leadIn = const Duration(seconds: 2),
  }) {
    final random = math.Random(seed);
    final notes = <RhythmNote>[];
    for (var beat = 0; beat < beats; beat++) {
      final lane = random.nextInt(lanes);
      notes.add(RhythmNote(beat: beat.toDouble(), lane: lane));
      if (random.nextDouble() < _chordChance) {
        notes.add(
          RhythmNote(
            beat: beat.toDouble(),
            lane: (lane + 1 + random.nextInt(lanes - 1)) % lanes,
          ),
        );
      }
      if (beat + 1 < beats && random.nextDouble() < _offBeatChance) {
        notes.add(RhythmNote(beat: beat + 0.5, lane: random.nextInt(lanes)));
      }
    }
    return RhythmSong(
      bpm: bpm,
      leadIn: leadIn,
      beats: beats,
      notes: List.unmodifiable(notes),
    );
  }

  static const _chordChance = 0.1;
  static const _offBeatChance = 0.3;

  /// Built-in 34 second track: **120 BPM, 2.0 s lead-in, 64 beats**, so
  /// beat k sounds at 2.0 + k * 0.5 s and the song ends at 34.0 s.
  /// Intro (beats 0–15) quarter notes, build-up (16–47) with eighths and
  /// chords, outro (48–63) sparser. Notes sit on whole and half beats only.
  static const demo = RhythmSong(
    bpm: 120,
    leadIn: Duration(seconds: 2),
    beats: 64,
    notes: _demoNotes,
  );

  final double bpm;

  /// Silence before beat 0, so the first notes have time to fall in.
  final Duration leadIn;

  /// Song length in beats after the lead-in.
  final int beats;

  /// Sorted by beat.
  final List<RhythmNote> notes;

  double get secondsPerBeat => Duration.secondsPerMinute / bpm;

  /// When [beat] should be hit, in seconds from the song start.
  double timeOf(double beat) => _seconds(leadIn) + beat * secondsPerBeat;

  Duration get length => Duration(
    microseconds: (timeOf(beats.toDouble()) * Duration.microsecondsPerSecond)
        .round(),
  );

  static double _seconds(Duration duration) =>
      duration.inMicroseconds / Duration.microsecondsPerSecond;
}

const _demoNotes = [
  RhythmNote(beat: 0, lane: 0),
  RhythmNote(beat: 1, lane: 1),
  RhythmNote(beat: 2, lane: 2),
  RhythmNote(beat: 3, lane: 3),
  RhythmNote(beat: 4, lane: 3),
  RhythmNote(beat: 5, lane: 2),
  RhythmNote(beat: 6, lane: 1),
  RhythmNote(beat: 7, lane: 0),
  RhythmNote(beat: 8, lane: 0),
  RhythmNote(beat: 9, lane: 2),
  RhythmNote(beat: 10, lane: 1),
  RhythmNote(beat: 11, lane: 3),
  RhythmNote(beat: 12, lane: 0),
  RhythmNote(beat: 13, lane: 2),
  RhythmNote(beat: 14, lane: 1),
  RhythmNote(beat: 15, lane: 3),
  RhythmNote(beat: 16, lane: 0),
  RhythmNote(beat: 17, lane: 2),
  RhythmNote(beat: 17.5, lane: 0),
  RhythmNote(beat: 18, lane: 1),
  RhythmNote(beat: 19, lane: 3),
  RhythmNote(beat: 20, lane: 2),
  RhythmNote(beat: 21, lane: 0),
  RhythmNote(beat: 21.5, lane: 2),
  RhythmNote(beat: 22, lane: 3),
  RhythmNote(beat: 23, lane: 1),
  RhythmNote(beat: 23, lane: 2),
  RhythmNote(beat: 24, lane: 0),
  RhythmNote(beat: 25, lane: 2),
  RhythmNote(beat: 25.5, lane: 0),
  RhythmNote(beat: 26, lane: 1),
  RhythmNote(beat: 27, lane: 3),
  RhythmNote(beat: 27.5, lane: 1),
  RhythmNote(beat: 28, lane: 2),
  RhythmNote(beat: 29, lane: 0),
  RhythmNote(beat: 29.5, lane: 2),
  RhythmNote(beat: 30, lane: 3),
  RhythmNote(beat: 31, lane: 1),
  RhythmNote(beat: 31, lane: 2),
  RhythmNote(beat: 31.5, lane: 3),
  RhythmNote(beat: 32, lane: 0),
  RhythmNote(beat: 33, lane: 2),
  RhythmNote(beat: 33.5, lane: 0),
  RhythmNote(beat: 34, lane: 1),
  RhythmNote(beat: 35, lane: 3),
  RhythmNote(beat: 35.5, lane: 1),
  RhythmNote(beat: 36, lane: 2),
  RhythmNote(beat: 37, lane: 0),
  RhythmNote(beat: 37.5, lane: 2),
  RhythmNote(beat: 38, lane: 3),
  RhythmNote(beat: 39, lane: 1),
  RhythmNote(beat: 39, lane: 2),
  RhythmNote(beat: 39.5, lane: 3),
  RhythmNote(beat: 40, lane: 0),
  RhythmNote(beat: 41, lane: 2),
  RhythmNote(beat: 41.5, lane: 0),
  RhythmNote(beat: 42, lane: 1),
  RhythmNote(beat: 43, lane: 3),
  RhythmNote(beat: 43.5, lane: 1),
  RhythmNote(beat: 44, lane: 2),
  RhythmNote(beat: 45, lane: 0),
  RhythmNote(beat: 45.5, lane: 2),
  RhythmNote(beat: 46, lane: 3),
  RhythmNote(beat: 47, lane: 1),
  RhythmNote(beat: 47, lane: 2),
  RhythmNote(beat: 47.5, lane: 3),
  RhythmNote(beat: 48, lane: 3),
  RhythmNote(beat: 50, lane: 1),
  RhythmNote(beat: 52, lane: 2),
  RhythmNote(beat: 54, lane: 0),
  RhythmNote(beat: 56, lane: 3),
  RhythmNote(beat: 58, lane: 1),
  RhythmNote(beat: 60, lane: 2),
  RhythmNote(beat: 62, lane: 0),
  RhythmNote(beat: 62, lane: 3),
];
