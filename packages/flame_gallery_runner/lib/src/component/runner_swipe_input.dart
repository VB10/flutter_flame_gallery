import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_gallery_runner/src/game/runner_game.dart';
import 'package:flame_gallery_runner/src/logic/runner_types.dart';

/// Turns one drag into at most one [SwipeDirection], decided as soon as the
/// finger has travelled far enough. Extra pointers are ignored.
final class RunnerSwipeInput extends PositionComponent
    with DragCallbacks, HasGameReference<RunnerGame> {
  RunnerSwipeInput() : super(priority: 20);

  /// Minimum travel, as a fraction of the shorter screen side.
  static const _thresholdFactor = 0.04;

  int? _activePointer;
  bool _decided = false;
  final Vector2 _travel = Vector2.zero();

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    this.size = size;
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    if (_activePointer != null) return;
    _activePointer = event.pointerId;
    _decided = false;
    _travel.setZero();
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (event.pointerId != _activePointer || _decided) return;
    _travel.add(event.localDelta);
    final threshold = math.min(size.x, size.y) * _thresholdFactor;
    if (_travel.length < threshold) return;
    _decided = true;
    game.onSwipe(SwipeDirection.fromDelta(_travel.x, _travel.y));
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    if (event.pointerId == _activePointer) _activePointer = null;
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    if (event.pointerId == _activePointer) _activePointer = null;
  }
}
