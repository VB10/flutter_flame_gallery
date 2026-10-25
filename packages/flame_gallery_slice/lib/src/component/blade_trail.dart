import 'dart:ui';

import 'package:flame/components.dart';

/// Fading, tapering line that follows the finger.
final class BladeTrail extends Component {
  BladeTrail({required Color color, required Color glow})
    : _core = Paint()
        ..color = color
        ..strokeCap = StrokeCap.round,
      _glow = Paint()
        ..color = glow
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowBlur);

  static const _lifetime = 0.16;
  static const _maxWidth = 9.0;
  static const _glowBlur = 6.0;
  static const _glowWidthFactor = 2.2;

  final Paint _core;
  final Paint _glow;
  final List<_TrailPoint> _points = [];

  /// [startsStroke] breaks the line so separate swipes are not joined.
  void addPoint(Vector2 point, {bool startsStroke = false}) =>
      _points.add(_TrailPoint(point.clone(), startsStroke: startsStroke));

  void clear() => _points.clear();

  @override
  void update(double dt) {
    for (final point in _points) {
      point.age += dt;
    }
    _points.removeWhere((point) => point.age >= _lifetime);
  }

  @override
  void render(Canvas canvas) {
    final count = _points.length;
    for (var i = 1; i < count; i++) {
      final from = _points[i - 1];
      final to = _points[i];
      if (to.startsStroke) continue;
      final width = _maxWidth * (i / count) * (1 - to.age / _lifetime);
      final a = from.position.toOffset();
      final b = to.position.toOffset();
      canvas
        ..drawLine(a, b, _glow..strokeWidth = width * _glowWidthFactor)
        ..drawLine(a, b, _core..strokeWidth = width);
    }
  }
}

final class _TrailPoint {
  _TrailPoint(this.position, {required this.startsStroke});

  final Vector2 position;
  final bool startsStroke;
  double age = 0;
}
