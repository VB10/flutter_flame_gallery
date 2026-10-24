import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_gallery_rhythm/src/game/rhythm_game.dart';

/// Lanes, separators, the glowing hit line and per-lane tap flashes. Also the
/// tap target: every pointer is handled independently, so chords work.
final class LaneBoard extends PositionComponent
    with TapCallbacks, HasGameReference<RhythmGame> {
  LaneBoard({
    required Color lane,
    required Color separator,
    required Color hitLine,
    required Color flash,
  }) : _lanePaint = Paint()..color = lane,
       _separatorPaint = Paint()
         ..color = separator
         ..strokeWidth = _separatorWidth,
       _hitPaint = Paint()
         ..color = hitLine
         ..strokeWidth = _hitLineWidth,
       _glowPaint = Paint()
         ..color = hitLine.withValues(alpha: _glowAlpha)
         ..strokeWidth = _hitLineWidth * _glowWidthFactor
         ..maskFilter = const MaskFilter.blur(BlurStyle.normal, _glowBlur),
       _flashColor = flash;

  static const _separatorWidth = 1.5;
  static const _hitLineWidth = 4.0;
  static const _glowAlpha = 0.6;
  static const _glowWidthFactor = 4.0;
  static const _glowBlur = 8.0;
  static const _flashSeconds = 0.18;
  static const _flashAlpha = 0.35;

  final Paint _lanePaint;
  final Paint _separatorPaint;
  final Paint _hitPaint;
  final Paint _glowPaint;
  final Color _flashColor;
  final Paint _flashPaint = Paint();
  List<double> _flash = const [];

  void flashLane(int lane) {
    if (lane < _flash.length) _flash[lane] = _flashSeconds;
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
    _flash = List.filled(game.config.lanes, 0);
  }

  @override
  void update(double dt) {
    for (var i = 0; i < _flash.length; i++) {
      if (_flash[i] > 0) _flash[i] -= dt;
    }
  }

  @override
  void render(Canvas canvas) {
    final layout = game.layout;
    canvas.drawRect(size.toRect(), _lanePaint);
    for (var lane = 0; lane < layout.lanes; lane++) {
      final left = layout.laneWidth * lane;
      final flash = lane < _flash.length ? _flash[lane] : 0.0;
      if (flash > 0) {
        _flashPaint.color = _flashColor.withValues(
          alpha: _flashAlpha * flash / _flashSeconds,
        );
        canvas.drawRect(
          Rect.fromLTWH(left, 0, layout.laneWidth, size.y),
          _flashPaint,
        );
      }
      if (lane > 0) {
        canvas.drawLine(Offset(left, 0), Offset(left, size.y), _separatorPaint);
      }
    }
    final hitStart = Offset(0, layout.hitY);
    final hitEnd = Offset(size.x, layout.hitY);
    canvas
      ..drawLine(hitStart, hitEnd, _glowPaint)
      ..drawLine(hitStart, hitEnd, _hitPaint);
  }

  @override
  void onTapDown(TapDownEvent event) {
    final lane = game.layout.laneAt(event.localPosition.x);
    if (lane != null) game.tapLane(lane);
  }
}
