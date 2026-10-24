import 'package:flame_gallery_rhythm/flame_gallery_rhythm.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('demo song', () {
    const song = RhythmSong.demo;

    test('is 120 BPM, 2 s lead-in, 64 beats, 34 s long', () {
      expect(song.bpm, 120);
      expect(song.leadIn, const Duration(seconds: 2));
      expect(song.beats, 64);
      expect(song.length, const Duration(seconds: 34));
    });

    test('beat k sounds at 2.0 + k * 0.5 s', () {
      expect(song.timeOf(0), 2.0);
      expect(song.timeOf(1), 2.5);
      expect(song.timeOf(16.5), 10.25);
      expect(song.timeOf(63), 33.5);
    });

    test('notes are sorted, on whole or half beats, inside the song', () {
      final beats = song.notes.map((n) => n.beat).toList();
      expect(beats, [...beats]..sort());
      for (final note in song.notes) {
        expect((note.beat * 2) % 1, 0, reason: 'beat ${note.beat}');
        expect(note.beat, inInclusiveRange(0, song.beats - 1));
        expect(note.lane, inInclusiveRange(0, 3));
      }
    });

    test('intro is quarter notes, build-up has eighths and chords', () {
      final intro = song.notes.where((n) => n.beat < 16);
      expect(intro.every((n) => n.beat == n.beat.roundToDouble()), isTrue);
      final buildUp = song.notes.where((n) => n.beat >= 16 && n.beat < 48);
      expect(buildUp.any((n) => n.beat != n.beat.roundToDouble()), isTrue);
      final perBeat = <double, int>{};
      for (final note in buildUp) {
        perBeat[note.beat] = (perBeat[note.beat] ?? 0) + 1;
      }
      expect(perBeat.values.any((count) => count > 1), isTrue);
    });
  });

  group('generated', () {
    test('same seed gives the same chart', () {
      expect(
        RhythmSong.generated(seed: 7).notes,
        RhythmSong.generated(seed: 7).notes,
      );
    });

    test('different seeds differ', () {
      expect(
        RhythmSong.generated(seed: 1).notes,
        isNot(RhythmSong.generated(seed: 2).notes),
      );
    });

    test('respects beats and lanes', () {
      final song = RhythmSong.generated(beats: 16, lanes: 3, seed: 4);
      expect(song.notes, isNotEmpty);
      for (final note in song.notes) {
        expect(note.beat, lessThan(16));
        expect(note.lane, inInclusiveRange(0, 2));
      }
    });
  });
}
