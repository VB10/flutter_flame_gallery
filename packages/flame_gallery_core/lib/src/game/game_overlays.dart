import 'package:flame_gallery_core/src/game/game_phase.dart';

/// Overlay keys shared by every gallery game.
abstract final class GameOverlays {
  static const start = 'gallery.start';
  static const hud = 'gallery.hud';
  static const pause = 'gallery.pause';
  static const gameOver = 'gallery.gameOver';

  static const List<String> all = [start, hud, pause, gameOver];

  static List<String> forPhase(GamePhase phase) => switch (phase) {
    GamePhase.ready => const [start],
    GamePhase.playing => const [hud],
    GamePhase.paused => const [hud, pause],
    GamePhase.over => const [gameOver],
  };
}
