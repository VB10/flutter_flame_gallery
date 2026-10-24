/// Stable `Semantics.identifier`s of the shared overlays and HUD, for UI tests
/// (Maestro, Patrol, integration_test) in host apps. Language independent.
abstract final class GalleryKeys {
  static const startPanel = 'gallery_start_panel';
  static const pausePanel = 'gallery_pause_panel';
  static const gameOverPanel = 'gallery_game_over_panel';

  static const startButton = 'gallery_start_button';
  static const pauseButton = 'gallery_pause_button';
  static const resumeButton = 'gallery_resume_button';
  static const playAgainButton = 'gallery_play_again_button';
  static const closeButton = 'gallery_close_button';

  static const finalScore = 'gallery_final_score';

  static const hudScore = 'gallery_hud_score';
  static const hudTimer = 'gallery_hud_timer';
  static const hudLives = 'gallery_hud_lives';
}
