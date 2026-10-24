import 'package:flame_gallery_rhythm/src/logic/note_chart.dart';
import 'package:flame_gallery_rhythm/src/logic/rhythm_judge.dart';
import 'package:flutter_test/flutter_test.dart';

NoteChart _chart() => NoteChart([
  ChartNote(time: 2, lane: 0),
  ChartNote(time: 1, lane: 0),
  ChartNote(time: 1, lane: 1),
]);

void main() {
  test('notes are sorted by time', () {
    expect(_chart().notes.map((n) => n.time), [1, 1, 2]);
  });

  test('a tap judges the closest open note of its lane only', () {
    final chart = _chart();
    final hit = chart.tap(0, 1.1);
    expect(hit?.judgement, Judgement.great);
    expect(chart.notes[hit!.index].lane, 0);
    expect(chart.notes.where((n) => n.lane == 1).single.isJudged, isFalse);
  });

  test('taps outside every window are ignored', () {
    final chart = _chart();
    expect(chart.tap(0, 1.5), isNull);
    expect(chart.notes.any((n) => n.isJudged), isFalse);
  });

  test('a judged note cannot be hit twice', () {
    final chart = _chart()..tap(1, 1);
    expect(chart.tap(1, 1), isNull);
  });

  test('expire marks notes past the good window as misses', () {
    final chart = _chart()..tap(1, 1);
    final missed = chart.expire(1 + RhythmJudge.goodWindow + 0.01);
    expect(missed, hasLength(1));
    expect(chart.notes[missed.single].judgement, Judgement.miss);
    expect(chart.allJudged, isFalse);
    chart.expire(3);
    expect(chart.allJudged, isTrue);
  });

  test('reset reopens every note', () {
    final chart = _chart()
      ..expire(5)
      ..reset();
    expect(chart.notes.any((n) => n.isJudged), isFalse);
  });
}
