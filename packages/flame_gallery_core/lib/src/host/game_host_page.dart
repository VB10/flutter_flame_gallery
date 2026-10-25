import 'dart:async';

import 'package:flame/game.dart';
import 'package:flame_gallery_core/src/game/gallery_flame_game.dart';
import 'package:flame_gallery_core/src/game/gallery_game.dart';
import 'package:flame_gallery_core/src/game/game_overlays.dart';
import 'package:flame_gallery_core/src/host/game_ui.dart';
import 'package:flame_gallery_core/src/model/game_event.dart';
import 'package:flame_gallery_core/src/model/game_result.dart';
import 'package:flame_gallery_core/src/overlay/game_over_overlay.dart';
import 'package:flame_gallery_core/src/overlay/hud_overlay.dart';
import 'package:flame_gallery_core/src/overlay/pause_overlay.dart';
import 'package:flame_gallery_core/src/overlay/start_overlay.dart';
import 'package:flame_gallery_core/src/sound/game_sounds.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

part 'mixin/game_host_page_mixin.dart';
part 'widget/_game_over_host.dart';
part 'widget/_hud_host.dart';
part 'widget/_pause_host.dart';
part 'widget/_start_host.dart';

/// Full screen host for one game session. Works as a route body or embedded.
///
/// [onClose] receives the last result (or `null` if the round never started).
/// When omitted the page pops itself with that result.
///
/// One page is one session: a rebuild with another [game] keeps the running
/// session. Give the page a new `key` to start over with a different game.
final class GameHostPage extends StatefulWidget {
  const GameHostPage({
    required this.game,
    this.onEvent,
    this.onClose,
    this.overlays = const GameOverlayBuilders(),
    this.sounds,
    this.immersive = true,
    super.key,
  });

  final GalleryGame game;
  final ValueChanged<GameEvent>? onEvent;
  final ValueChanged<GameResult?>? onClose;

  /// Replaces the built-in start / HUD / pause / game over overlays.
  final GameOverlayBuilders overlays;

  /// Receives sound cues (slice, coin, hit...). Silent when `null`.
  final GameSounds? sounds;

  /// Hides the system bars while the game is open (`immersiveSticky`) so
  /// edge swipes reveal the bars instead of firing Android's back gesture
  /// mid-swipe. Restores [SystemUiMode.edgeToEdge] on close; pass `false` if
  /// the host app manages system UI itself.
  final bool immersive;

  @override
  State<GameHostPage> createState() => _GameHostPageState();
}

final class _GameHostPageState extends State<GameHostPage>
    with _GameHostPageMixin {
  @override
  Widget build(BuildContext context) {
    final game = widget.game;
    return Theme(
      data: game.theme.toThemeData(context),
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (!didPop) _handleBack();
        },
        child: GameWidget<GalleryFlameGame>(
          game: flameGame,
          backgroundBuilder: game.theme.background?.build,
          overlayBuilderMap: {
            GameOverlays.start: (context, g) => _StartHost(host: this, game: g),
            GameOverlays.hud: (context, g) => _HudHost(host: this, game: g),
            GameOverlays.pause: (context, g) => _PauseHost(host: this, game: g),
            GameOverlays.gameOver: (context, g) =>
                _GameOverHost(host: this, game: g),
          },
        ),
      ),
    );
  }
}
