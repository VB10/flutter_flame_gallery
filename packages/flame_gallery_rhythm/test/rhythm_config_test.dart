import 'package:flame_gallery_rhythm/flame_gallery_rhythm.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('copyWith clears nullable fields and keeps omitted ones', () {
    const config = RhythmConfig(
      missLimit: 5,
      audioLatency: Duration(milliseconds: 150),
    );

    final relaxed = config.copyWith(missLimit: () => null);

    expect(relaxed.missLimit, isNull);
    expect(relaxed.audioLatency, const Duration(milliseconds: 150));
    expect(config.copyWith().missLimit, 5);
  });
}
