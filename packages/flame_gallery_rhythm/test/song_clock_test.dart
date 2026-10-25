import 'package:flame_gallery_rhythm/src/logic/song_clock.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SongClock', () {
    test('runs on frame time without audio', () {
      final clock = SongClock(hasAudio: false)
        ..advance(0.5)
        ..advance(0.25);
      expect(clock.time, 0.75);
    });

    test('follows the reported position minus latency', () {
      final clock = SongClock(hasAudio: true, latency: 0.25)
        ..advance(0.016, audioPosition: 2);
      expect(clock.time, 1.75);
      expect(clock.at(3), 2.75);
      expect(clock.at(null), 1.75);
    });

    test('waits for the first report, then runs on its own', () {
      final clock = SongClock(hasAudio: true, startTimeout: 0.5)
        ..advance(0.25)
        ..advance(0.25);
      expect(clock.time, 0);

      clock.advance(0.25);
      expect(clock.time, 0.25);
    });

    test('keeps running when the player stops reporting', () {
      final clock = SongClock(hasAudio: true)
        ..advance(0.016, audioPosition: 1)
        ..advance(0.5);
      expect(clock.time, 1.5);
    });

    test('reset starts the song over', () {
      final clock = SongClock(hasAudio: true)
        ..advance(0.016, audioPosition: 4)
        ..reset()
        ..advance(0.5);
      expect(clock.time, 0);
    });
  });
}
