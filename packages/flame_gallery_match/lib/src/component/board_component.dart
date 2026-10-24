import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_gallery_match/src/game/match_game.dart';
import 'package:flame_gallery_match/src/logic/cell.dart';
import 'package:flutter/material.dart' show ColorScheme;

/// Draws the cell grid, clips the pieces and turns taps/drags into swaps.
final class BoardComponent extends PositionComponent
    with TapCallbacks, DragCallbacks, HasGameReference<MatchGame> {
  BoardComponent({
    required this.rows,
    required this.columns,
    required ColorScheme colors,
  }) : _light = Paint()..color = colors.surfaceContainerHigh,
       _dark = Paint()..color = colors.surfaceContainer,
       _selection = Paint()
         ..color = colors.primary
         ..style = PaintingStyle.stroke
         ..strokeWidth = _selectionWidth;

  static const _cornerFactor = 0.18;
  static const _insetFactor = 0.04;
  static const _selectionWidth = 3.0;

  /// Drag distance, as a fraction of a cell, that commits a swap direction.
  static const _dragThreshold = 0.35;

  final int rows;
  final int columns;
  final Paint _light;
  final Paint _dark;
  final Paint _selection;

  double cellSize = 0;
  Cell? selected;

  Cell? _dragOrigin;
  final Vector2 _dragDelta = Vector2.zero();
  bool _dragCommitted = false;

  Vector2 centerOf(Cell cell) =>
      Vector2((cell.column + 0.5) * cellSize, (cell.row + 0.5) * cellSize);

  Cell? cellAt(Vector2 local) {
    if (cellSize <= 0) return null;
    final row = (local.y / cellSize).floor();
    final column = (local.x / cellSize).floor();
    if (row < 0 || row >= rows || column < 0 || column >= columns) return null;
    return (row: row, column: column);
  }

  @override
  void render(Canvas canvas) {
    // Clip stays active for the children: pieces dropping in from above the
    // board stay hidden until they enter it.
    canvas.clipRect(size.toRect());
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        canvas.drawRRect(
          _cellRect((row: row, column: column)),
          (row + column).isEven ? _light : _dark,
        );
      }
    }
    final selected = this.selected;
    if (selected != null) canvas.drawRRect(_cellRect(selected), _selection);
  }

  @override
  void onTapUp(TapUpEvent event) {
    if (!game.canInteract) return;
    final cell = cellAt(event.localPosition);
    if (cell == null) return;
    final current = selected;
    if (current == null || !current.isAdjacentTo(cell)) {
      selected = current == cell ? null : cell;
      return;
    }
    selected = null;
    game.requestSwap(current, cell);
  }

  @override
  void onDragStart(DragStartEvent event) {
    super.onDragStart(event);
    _dragOrigin = game.canInteract ? cellAt(event.localPosition) : null;
    _dragDelta.setZero();
    _dragCommitted = false;
  }

  @override
  void onDragUpdate(DragUpdateEvent event) {
    super.onDragUpdate(event);
    final origin = _dragOrigin;
    if (origin == null || _dragCommitted) return;
    _dragDelta.add(event.localDelta);
    if (_dragDelta.length < cellSize * _dragThreshold) return;
    _dragCommitted = true;
    final horizontal = _dragDelta.x.abs() > _dragDelta.y.abs();
    final target = horizontal
        ? (row: origin.row, column: origin.column + _dragDelta.x.sign.toInt())
        : (row: origin.row + _dragDelta.y.sign.toInt(), column: origin.column);
    selected = null;
    game.requestSwap(origin, target);
  }

  @override
  void onDragEnd(DragEndEvent event) {
    super.onDragEnd(event);
    _dragOrigin = null;
  }

  RRect _cellRect(Cell cell) {
    final inset = cellSize * _insetFactor;
    return RRect.fromRectAndRadius(
      Rect.fromLTWH(
        cell.column * cellSize + inset,
        cell.row * cellSize + inset,
        cellSize - inset * 2,
        cellSize - inset * 2,
      ),
      Radius.circular(cellSize * _cornerFactor),
    );
  }
}
