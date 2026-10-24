import 'package:flame/components.dart';
import 'package:flame_gallery_slice/src/logic/slice_geometry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final center = Vector2(50, 50);

  test('segment through the circle hits', () {
    expect(
      segmentHitsCircle(Vector2(0, 50), Vector2(100, 50), center, 10),
      isTrue,
    );
  });

  test('segment passing beside the circle misses', () {
    expect(
      segmentHitsCircle(Vector2(0, 70), Vector2(100, 70), center, 10),
      isFalse,
    );
  });

  test('segment that stops before the circle misses', () {
    expect(
      segmentHitsCircle(Vector2(0, 50), Vector2(30, 50), center, 10),
      isFalse,
    );
  });

  test('zero length segment inside the circle hits', () {
    expect(
      segmentHitsCircle(Vector2(52, 52), Vector2(52, 52), center, 10),
      isTrue,
    );
  });
}
