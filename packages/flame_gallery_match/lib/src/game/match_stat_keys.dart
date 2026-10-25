/// Sweet Swap `GameResult.stats` keys, next to `GameStatKeys.endedBy`.
abstract final class MatchStatKeys {
  /// Swaps that made a match (bounced swaps are free).
  static const movesUsed = 'movesUsed';

  /// Deepest chain reaction: 1 for the swap's own match, 2+ for cascades.
  static const maxCascade = 'maxCascade';
}
