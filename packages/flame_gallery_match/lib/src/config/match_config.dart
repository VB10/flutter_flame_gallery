import 'package:flame_gallery_core/flame_gallery_core.dart';
import 'package:flame_gallery_match/src/config/match_piece.dart';
import 'package:flutter/foundation.dart';

/// Gameplay rules a host app can tune per campaign.
@immutable
final class MatchConfig {
  const MatchConfig({
    this.rows = 8,
    this.columns = 8,
    this.pieces = MatchPiece.sweets,
    this.moveLimit = 20,
    this.timeLimit,
    this.targetScore,
    this.pointsPerPiece = 10,
    this.background,
    this.seed,
  }) : assert(rows >= minSize && rows <= maxSize, 'rows must be 5..10'),
       assert(
         columns >= minSize && columns <= maxSize,
         'columns must be 5..10',
       ),
       assert(
         moveLimit != null || timeLimit != null,
         'Either moveLimit or timeLimit must be set, or the round never ends',
       ),
       assert(moveLimit == null || moveLimit > 0, 'moveLimit must be > 0'),
       assert(targetScore == null || targetScore > 0, 'targetScore > 0'),
       assert(pointsPerPiece > 0, 'pointsPerPiece must be > 0');

  static const minSize = 5;
  static const maxSize = 10;

  /// Fewer kinds than this make chains endless and boards trivial.
  static const minPieces = 4;

  final int rows;
  final int columns;

  /// At least [minPieces] kinds.
  final List<MatchPiece> pieces;

  /// Swaps allowed. `null` → unlimited (then [timeLimit] must be set).
  final int? moveLimit;

  /// `null` → no timer.
  final Duration? timeLimit;

  /// Reaching this score ends the round early as a win.
  final int? targetScore;

  /// Base points per cleared piece, multiplied by the cascade level.
  final int pointsPerPiece;

  /// Optional full screen background image, stretched to cover.
  final GameAsset? background;

  /// Fixes the board and refills, e.g. for a daily challenge where every
  /// player gets the same puzzle. `null` → a new board each round.
  final int? seed;

  MatchConfig copyWith({
    int? rows,
    int? columns,
    List<MatchPiece>? pieces,
    int? moveLimit,
    Duration? timeLimit,
    int? targetScore,
    int? pointsPerPiece,
    GameAsset? background,
    int? seed,
  }) => MatchConfig(
    rows: rows ?? this.rows,
    columns: columns ?? this.columns,
    pieces: pieces ?? this.pieces,
    moveLimit: moveLimit ?? this.moveLimit,
    timeLimit: timeLimit ?? this.timeLimit,
    targetScore: targetScore ?? this.targetScore,
    pointsPerPiece: pointsPerPiece ?? this.pointsPerPiece,
    background: background ?? this.background,
    seed: seed ?? this.seed,
  );
}
