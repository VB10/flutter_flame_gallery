/// A board coordinate. Row 0 is the top row.
typedef Cell = ({int row, int column});

extension CellNeighbours on Cell {
  bool isAdjacentTo(Cell other) =>
      (row - other.row).abs() + (column - other.column).abs() == 1;
}
