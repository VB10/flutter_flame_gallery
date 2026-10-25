import 'dart:collection';

/// Applies one animation stage and returns how long to wait before the next.
typedef Stage = double Function();

/// Runs stages one after another, each waiting out the duration the previous
/// one returned. Stages that take no time run in the same frame.
final class StageQueue {
  final ListQueue<Stage> _stages = ListQueue<Stage>();
  double _wait = 0;

  void add(Stage stage) => _stages.add(stage);

  void clear() {
    _stages.clear();
    _wait = 0;
  }

  /// Advances by [dt] seconds and runs every stage that has come due.
  void update(double dt) {
    if (_wait > 0) _wait -= dt;
    while (_wait <= 0 && _stages.isNotEmpty) {
      _wait = _stages.removeFirst()();
    }
  }
}
