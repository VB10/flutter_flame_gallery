import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame_gallery_runner/src/game/runner_game.dart';
import 'package:flame_gallery_runner/src/game/runner_layout.dart';

/// The path and its scrolling dashed lane dividers.
final class RunnerTrack extends Component with HasGameReference<RunnerGame> {
  RunnerTrack({required Color pathColor, required Color stripeColor})
    : _path = Paint()..color = pathColor,
      _stripe = Paint()
        ..color = stripeColor
        ..strokeCap = StrokeCap.round,
      super(priority: -1);

  static const _dashFactor = 0.5;
  static const _stripeWidthFactor = 0.05;

  final Paint _path;
  final Paint _stripe;

  @override
  void render(Canvas canvas) {
    final layout = game.layout;
    canvas.drawRect(
      Rect.fromLTWH(layout.pathLeft, 0, layout.pathWidth, layout.height),
      _path,
    );

    final dash = layout.laneWidth * _dashFactor;
    final period = dash * 2;
    final offset = game.traveled % period;
    _stripe.strokeWidth = layout.laneWidth * _stripeWidthFactor;
    for (var lane = 1; lane < RunnerLayout.laneCount; lane++) {
      final x = layout.pathLeft + layout.laneWidth * lane;
      for (var y = offset - period; y < layout.height; y += period) {
        canvas.drawLine(Offset(x, y), Offset(x, y + dash), _stripe);
      }
    }
  }
}
