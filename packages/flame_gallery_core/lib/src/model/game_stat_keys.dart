/// `GameResult.stats` keys shared by every game. Game specific keys live in
/// each game package (`SliceStatKeys`, `MatchStatKeys`, ...).
abstract final class GameStatKeys {
  /// Name of the game's end cause enum value; `quit` after a host close.
  static const endedBy = 'endedBy';
}
