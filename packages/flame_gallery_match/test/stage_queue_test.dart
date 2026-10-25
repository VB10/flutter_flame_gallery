import 'package:flame_gallery_match/src/logic/stage_queue.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('StageQueue', () {
    test('waits out a stage, counted from the frame after it ran', () {
      final log = <String>[];
      final queue = StageQueue()
        ..add(() {
          log.add('a');
          return 0.25;
        })
        ..add(() {
          log.add('b');
          return 0;
        })
        ..update(0.1);
      expect(log, ['a']);

      queue.update(0.125);
      expect(log, ['a']);

      queue.update(0.125);
      expect(log, ['a', 'b']);
    });

    test('stages without a duration run in the same frame', () {
      final log = <int>[];
      StageQueue()
        ..add(() {
          log.add(1);
          return 0;
        })
        ..add(() {
          log.add(2);
          return 0;
        })
        ..update(0);
      expect(log, [1, 2]);
    });

    test('clear drops pending stages and the running wait', () {
      final log = <String>[];
      StageQueue()
        ..add(() => 1)
        ..add(() {
          log.add('late');
          return 0;
        })
        ..update(0)
        ..clear()
        ..add(() {
          log.add('fresh');
          return 0;
        })
        ..update(0);
      expect(log, ['fresh']);
    });
  });
}
