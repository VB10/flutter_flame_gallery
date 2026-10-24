import 'package:flame_gallery_match/src/logic/cell.dart';
import 'package:flutter/foundation.dart';

@immutable
final class PieceFall {
  const PieceFall({required this.from, required this.to});

  final Cell from;
  final Cell to;
}

@immutable
final class PieceSpawn {
  const PieceSpawn({
    required this.cell,
    required this.piece,
    required this.startRow,
  });

  final Cell cell;
  final int piece;

  /// Virtual row above the board (negative) the piece drops in from.
  final int startRow;
}

/// One clear → gravity → refill round of a resolve, in animation order.
@immutable
final class CascadeStep {
  const CascadeStep({
    required this.level,
    required this.cleared,
    required this.falls,
    required this.spawns,
  });

  /// 1 for the swap's own match, 2+ for chain reactions.
  final int level;
  final Set<Cell> cleared;
  final List<PieceFall> falls;
  final List<PieceSpawn> spawns;

  int score(int pointsPerPiece) => cleared.length * pointsPerPiece * level;
}
