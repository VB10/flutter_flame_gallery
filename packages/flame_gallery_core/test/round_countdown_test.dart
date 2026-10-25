import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RoundCountdown', () {
    test('publishes whole seconds, rounded up', () {
      final countdown = RoundCountdown(const Duration(milliseconds: 2500));
      expect(countdown.secondsLeft.value, 3);

      expect(countdown.tick(0.6), isFalse);
      expect(countdown.secondsLeft.value, 2);
    });

    test('expires exactly once', () {
      final countdown = RoundCountdown(const Duration(seconds: 1));

      expect(countdown.tick(0.5), isFalse);
      expect(countdown.tick(0.6), isTrue);
      expect(countdown.secondsLeft.value, 0);
      expect(countdown.tick(1), isFalse);
    });

    test('reset restores the full limit', () {
      final countdown = RoundCountdown(const Duration(seconds: 2))
        ..tick(2)
        ..reset();

      expect(countdown.secondsLeft.value, 2);
      expect(countdown.tick(1), isFalse);
    });

    test('a null limit never expires', () {
      final countdown = RoundCountdown(null);

      expect(countdown.tick(1000), isFalse);
      expect(countdown.secondsLeft.value, isNull);
    });
  });

  test('Duration.asSeconds keeps the fraction', () {
    expect(const Duration(milliseconds: 1250).asSeconds, 1.25);
  });
}
