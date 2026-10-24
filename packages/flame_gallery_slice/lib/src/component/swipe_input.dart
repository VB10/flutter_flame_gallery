import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_gallery_slice/src/game/slice_game.dart';

/// Full screen drag catcher that turns gestures into slice strokes.
/// Tracks a single finger; extra pointers are ignored until it lifts.
final class SwipeInput extends PositionComponent
    with DragCallbacks, HasGameReference<SliceGame> {
  int? _activePointer;

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
    game.beginStroke(event.localPosition);
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    if (event.pointerId != _activePointer) return;
    game.swipe(event.localStartPosition, event.localEndPosition);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _release(event.pointerId);
  }

  @override
  void onDragCancel(DragCancelEvent event) {
    super.onDragCancel(event);
    _release(event.pointerId);
  }

  void _release(int pointerId) {
    if (pointerId != _activePointer) return;
    _activePointer = null;
    game.endStroke();
  }
}
