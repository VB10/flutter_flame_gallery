import 'package:flame_gallery_match/src/component/piece_component.dart';
import 'package:flame_gallery_match/src/logic/cell.dart';

/// The [PieceComponent] drawn in each board cell. Animations update it as they
/// replay the board's moves; `null` marks a cleared cell awaiting its refill.
final class PieceGrid {
  PieceGrid({required this.rows, required this.columns})
    : _cells = List.generate(rows, (_) => List.filled(columns, null));

  final int rows;
  final int columns;
  final List<List<PieceComponent?>> _cells;

  /// Every cell, row by row from the top left.
  Iterable<Cell> get cells sync* {
    for (var row = 0; row < rows; row++) {
      for (var column = 0; column < columns; column++) {
        yield (row: row, column: column);
      }
    }
  }

  /// Every occupied cell with its piece.
  Iterable<(Cell, PieceComponent)> get entries sync* {
    for (final cell in cells) {
      final piece = this[cell];
      if (piece != null) yield (cell, piece);
    }
  }

  PieceComponent? operator [](Cell cell) => _cells[cell.row][cell.column];

  void operator []=(Cell cell, PieceComponent? piece) =>
      _cells[cell.row][cell.column] = piece;

  /// Empties [cell] and returns the piece that was there.
  PieceComponent? take(Cell cell) {
    final piece = this[cell];
    this[cell] = null;
    return piece;
  }

  void swap(Cell a, Cell b) {
    final piece = this[a];
    this[a] = this[b];
    this[b] = piece;
  }
}
