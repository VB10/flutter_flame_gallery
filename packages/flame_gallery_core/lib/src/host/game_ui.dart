import 'package:flame_gallery_core/src/game/game_phase.dart';
import 'package:flame_gallery_core/src/l10n/game_strings.dart';
import 'package:flame_gallery_core/src/model/game_result.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// What a custom overlay needs to drive the session.
@immutable
final class GameUi {
  const GameUi({
    required this.strings,
    required this.score,
    required this.phase,
    required this.result,
    required this.logo,
    required this.hud,
    required this.start,
    required this.pause,
    required this.resume,
    required this.close,
  });

  final GameStrings strings;
  final ValueListenable<int> score;
  final ValueListenable<GamePhase> phase;

  /// Set once the round is over, `null` before.
  final GameResult? Function() result;
  final ImageProvider? logo;

  /// The game's own HUD (lives, timer, combo...) for reuse inside a custom
  /// top bar.
  final Widget hud;

  /// Starts a round, also used for "play again".
  final VoidCallback start;
  final VoidCallback pause;
  final VoidCallback resume;

  /// Leaves the game and returns the last result to the host.
  final VoidCallback close;
}

typedef GameOverlayBuilder = Widget Function(BuildContext context, GameUi ui);

/// Replaces the built-in overlays. Anything left `null` keeps the default.
///
/// Custom overlays inherit the game's `Theme`. Keep `GalleryKeys` semantics
/// identifiers on your buttons if you run the Maestro suites against them.
@immutable
final class GameOverlayBuilders {
  const GameOverlayBuilders({this.start, this.hud, this.pause, this.gameOver});

  final GameOverlayBuilder? start;

  /// Replaces the whole top bar, including the pause button.
  final GameOverlayBuilder? hud;
  final GameOverlayBuilder? pause;
  final GameOverlayBuilder? gameOver;
}
