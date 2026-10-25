import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_rhythm/flame_gallery_rhythm.dart';
import 'package:flame_gallery_rhythm/src/logic/rhythm_judge.dart';
import 'package:flame_test/flame_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Notes at 1.0 s (lane 1) and 3.0 s (lane 2); song ends at 5.0 s.
const _song = RhythmSong(
  bpm: 60,
  leadIn: Duration(seconds: 1),
  beats: 4,
  notes: [RhythmNote(beat: 0, lane: 1), RhythmNote(beat: 2, lane: 2)],
);

final class _FakeAudio implements RhythmAudio {
  final calls = <String>[];
  Duration? fakePosition;

  @override
  Duration? get position => fakePosition;

  @override
  Future<void> start() async => calls.add('start');

  @override
  Future<void> pause() async => calls.add('pause');

  @override
  Future<void> resume() async => calls.add('resume');

  @override
  Future<void> stop() async => calls.add('stop');
}

RhythmGame Function() _game({
  int? missLimit,
  RhythmAudio? audio,
  Duration audioLatency = Duration.zero,
  RhythmLabels labels = RhythmLabels.en,
}) => () {
  final game = RhythmGame(
    config: RhythmConfig(
      song: _song,
      missLimit: missLimit,
      audioLatency: audioLatency,
    ),
    colors: ColorScheme.fromSeed(seedColor: Colors.indigo),
    gameId: NoteRush.id,
    audio: audio,
    labels: labels,
  );
  for (final name in GameOverlays.all) {
    game.overlays.addEntry(name, (_, _) => const SizedBox.shrink());
  }
  return game;
};

const double _step = 1 / 100;

void _advanceTo(RhythmGame game, double seconds) {
  while (game.isPlaying && game.songTime < seconds - _step / 2) {
    game.update(_step);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWithGame<RhythmGame>('a tap on time is perfect and scores', _game(), (
    game,
  ) async {
    game.start();
    _advanceTo(game, 1);
    game.tapLane(1);

    expect(game.countOf(Judgement.perfect), 1);
    expect(game.score.value, Judgement.perfect.points);
    expect(game.combo.value, 1);
  });

  testWithGame<RhythmGame>(
    'an early tap far from any note is ignored',
    _game(),
    (game) async {
      game.start();
      _advanceTo(game, 0.5);
      game.tapLane(1);

      expect(game.countOf(Judgement.perfect), 0);
      expect(game.countOf(Judgement.miss), 0);
    },
  );

  testWithGame<RhythmGame>('a note nobody taps becomes a miss', _game(), (
    game,
  ) async {
    game.start();
    _advanceTo(game, 1.3);

    expect(game.countOf(Judgement.miss), 1);
    expect(game.combo.value, 0);
    expect(game.phase.value, GamePhase.playing);
  });

  testWithGame<RhythmGame>(
    'reaching the miss limit ends the round',
    _game(missLimit: 1),
    (game) async {
      game.start();
      _advanceTo(game, 1.3);

      expect(game.phase.value, GamePhase.over);
      expect(game.missesLeft.value, 0);
      expect(
        game.result?.stats[GameStatKeys.endedBy],
        RhythmEndCause.tooManyMisses.name,
      );
    },
  );

  testWithGame<RhythmGame>('the song end ends the round', _game(), (
    game,
  ) async {
    game.start();
    _advanceTo(game, 5.05);

    expect(game.phase.value, GamePhase.over);
    expect(
      game.result?.stats[GameStatKeys.endedBy],
      RhythmEndCause.songEnd.name,
    );
    expect(game.result?.stats[RhythmStatKeys.miss], 2);
    expect(game.result?.stats[RhythmStatKeys.accuracy], 0);
  });

  testWithGame<RhythmGame>(
    'audio position drives the song clock',
    () =>
        _game(audio: _FakeAudio()..fakePosition = const Duration(seconds: 2))(),
    (game) async {
      game
        ..start()
        ..update(_step);
      expect(game.songTime, 2);
    },
  );

  testWithGame<RhythmGame>(
    'audio latency shifts the clock back to what the player hears',
    _game(
      audio: _FakeAudio()..fakePosition = const Duration(seconds: 2),
      audioLatency: const Duration(milliseconds: 200),
    ),
    (game) async {
      game
        ..start()
        ..update(_step);
      expect(game.songTime, closeTo(1.8, 1e-9));
    },
  );

  testWithGame<RhythmGame>(
    'the clock waits for the music to report, then runs on its own',
    _game(audio: _FakeAudio()),
    (game) async {
      game
        ..start()
        ..update(0.5)
        ..update(0.5);
      expect(game.songTime, 0);

      game.update(0.3);
      expect(game.songTime, closeTo(0.3, 1e-9));
    },
  );

  final droppingAudio = _FakeAudio()..fakePosition = const Duration(seconds: 2);
  testWithGame<RhythmGame>(
    'a missing position report continues from the music, no jump',
    _game(audio: droppingAudio),
    (game) async {
      game
        ..start()
        ..update(_step);
      droppingAudio.fakePosition = null;
      game.update(0.1);
      expect(game.songTime, closeTo(2.1, 1e-9));
    },
  );

  testWithGame<RhythmGame>(
    'judgement labels come from RhythmLabels',
    _game(labels: RhythmLabels.tr),
    (game) async {
      game.start();
      _advanceTo(game, 1);
      game.tapLane(1);
      await game.ready();

      final labels = game.children.whereType<FloatingLabel>();
      expect(labels.single.text, RhythmLabels.tr.perfect);
    },
  );

  final audio = _FakeAudio();
  testWithGame<RhythmGame>(
    'audio follows start, pause, resume and finish',
    _game(audio: audio),
    (game) async {
      game
        ..start()
        ..pause()
        ..resume()
        ..finish();
      await Future<void>.delayed(Duration.zero);
      expect(audio.calls, ['start', 'pause', 'resume', 'stop']);
    },
  );

  final quitAudio = _FakeAudio();
  testWithGame<RhythmGame>(
    'quitting stops the music once',
    _game(audio: quitAudio),
    (game) async {
      game
        ..start()
        ..quit();
      await Future<void>.delayed(Duration.zero);
      expect(quitAudio.calls, ['start', 'stop']);
    },
  );

  testWithGame<RhythmGame>('play again resets the chart and stats', _game(), (
    game,
  ) async {
    game.start();
    _advanceTo(game, 5.05);
    game.start();

    expect(game.countOf(Judgement.miss), 0);
    expect(game.combo.value, 0);
    expect(game.accuracy.value, 100);
    expect(game.songTime, 0);
  });
}
