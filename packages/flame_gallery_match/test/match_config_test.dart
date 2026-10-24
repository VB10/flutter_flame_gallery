import 'package:flame_gallery_match/flame_gallery_match.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('copyWith clears nullable fields and keeps omitted ones', () {
    const config = MatchConfig(targetScore: 900, seed: 7);

    final open = config.copyWith(targetScore: () => null);
    final random = config.copyWith(seed: () => null, moveLimit: () => 10);

    expect(open.targetScore, isNull);
    expect(open.seed, 7);
    expect(random.seed, isNull);
    expect(random.moveLimit, 10);
    expect(random.targetScore, 900);
  });
}
