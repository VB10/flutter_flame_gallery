// Semantics identifiers. Sources of truth:
//   apps/example/lib/app/maestro_keys.dart          (home)
//   packages/flame_gallery_core/lib/src/testing/gallery_keys.dart (overlays, HUD)
//   packages/flame_gallery_runner/lib/src/testing/runner_keys.dart
//   packages/flame_gallery_match/lib/src/testing/match_keys.dart
//   packages/flame_gallery_rhythm/lib/src/testing/rhythm_keys.dart
output.keys = {
    // Home
    HOME_VIEW: 'home_view',
    RESULT_CARD: 'last_result_card',
    RESULT_GAME: 'last_result_game',
    RESULT_SCORE: 'last_result_score',
    RESULT_REASON: 'last_result_reason',
    RESULT_ENDED_BY: 'last_result_ended_by',
    CARD_FRUIT_SLICE: 'demo_card_fruit_slice',
    CARD_FRUIT_SLICE_SURVIVAL: 'demo_card_fruit_slice_survival',
    CARD_FRUIT_SLICE_BRAND: 'demo_card_fruit_slice_brand',
    CARD_RUNNER: 'demo_card_runner',
    CARD_RUNNER_TIMED: 'demo_card_runner_timed',
    CARD_SWEET_SWAP: 'demo_card_sweet_swap',
    CARD_SWEET_SWAP_TARGET: 'demo_card_sweet_swap_target',
    CARD_SWEET_SWAP_DAILY: 'demo_card_sweet_swap_daily',
    CARD_NOTE_RUSH: 'demo_card_note_rush',
    CARD_NOTE_RUSH_HARD: 'demo_card_note_rush_hard',

    // Gallery overlays
    START_PANEL: 'gallery_start_panel',
    PAUSE_PANEL: 'gallery_pause_panel',
    GAME_OVER_PANEL: 'gallery_game_over_panel',
    START_BUTTON: 'gallery_start_button',
    PAUSE_BUTTON: 'gallery_pause_button',
    RESUME_BUTTON: 'gallery_resume_button',
    PLAY_AGAIN_BUTTON: 'gallery_play_again_button',
    CLOSE_BUTTON: 'gallery_close_button',
    FINAL_SCORE: 'gallery_final_score',

    // HUD
    HUD_SCORE: 'gallery_hud_score',
    HUD_TIMER: 'gallery_hud_timer',
    HUD_LIVES: 'gallery_hud_lives',
    HUD_RUNNER_COINS: 'runner_hud_coins',
    HUD_RUNNER_DISTANCE: 'runner_hud_distance',
    HUD_MATCH_MOVES: 'match_hud_moves',
    HUD_MATCH_TARGET: 'match_hud_target',
    HUD_RHYTHM_COMBO: 'rhythm_hud_combo',
    HUD_RHYTHM_ACCURACY: 'rhythm_hud_accuracy',

    // System UI (not ours)
    ANDROID_IMMERSIVE_OK: 'Got it',
}

// GameResult values shown on the home result card.
output.values = {
    REASON_COMPLETED: 'completed',
    REASON_QUIT: 'quit',
    GAME_FRUIT_SLICE: 'fruit_slice',
    GAME_RUNNER: 'endless_runner',
    GAME_SWEET_SWAP: 'sweet_swap',
    GAME_NOTE_RUSH: 'note_rush',
}
