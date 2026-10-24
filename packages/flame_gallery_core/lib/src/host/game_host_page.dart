import 'dart:async';

import 'package:flame/game.dart';
import 'package:flame_gallery_core/src/game/gallery_flame_game.dart';
import 'package:flame_gallery_core/src/game/gallery_game.dart';
import 'package:flame_gallery_core/src/game/game_overlays.dart';
import 'package:flame_gallery_core/src/model/game_event.dart';
import 'package:flame_gallery_core/src/model/game_result.dart';
import 'package:flame_gallery_core/src/overlay/game_over_overlay.dart';
import 'package:flame_gallery_core/src/overlay/hud_overlay.dart';
import 'package:flame_gallery_core/src/overlay/pause_overlay.dart';
import 'package:flame_gallery_core/src/overlay/start_overlay.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    this.immersive = true,
    super.key,
  });

  final GalleryGame game;
  final ValueChanged<GameEvent>? onEvent;
  final ValueChanged<GameResult?>? onClose;

  /// Hides the system bars while the game is open (`immersiveSticky`) so
  /// edge swipes reveal the bars instead of firing Android's back gesture
  /// mid-swipe. Restores [SystemUiMode.edgeToEdge] on close; pass `false` if
  /// the host app manages system UI itself.
  final bool immersive;

  @override
  State<GameHostPage> createState() => _GameHostPageState();
}

final class _GameHostPageState extends State<GameHostPage> {
  GalleryFlameGame? _flameGame;
  StreamSubscription<GameEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    if (widget.immersive) {
      unawaited(
        SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky),
      );
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_flameGame == null) _createGame();
  }

  void _createGame() {
    final flameGame = widget.game.createGame(
      widget.game.theme.resolveColors(context),
    );
    _flameGame = flameGame;
    // Reads widget.onEvent on every event, so a new callback from a rebuild is
    // picked up without re-subscribing.
    _subscription = flameGame.events.listen(
      (event) => widget.onEvent?.call(event),
    );
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    if (widget.immersive) {
      unawaited(SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge));
    }
    super.dispose();
  }

  void _close() {
    final result = _flameGame?.quit();
    final onClose = widget.onClose;
    if (onClose != null) {
      onClose(result);
    } else {
      Navigator.of(context).pop(result);
    }
  }

  void _handleBack() {
    final flameGame = _flameGame;
    if (flameGame != null && flameGame.isPlaying) {
      flameGame.pause();
    } else {
      _close();
    }
  }

  @override
  Widget build(BuildContext context) {
    final flameGame = _flameGame!;
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
          overlayBuilderMap: {
            GameOverlays.start: (_, g) => StartOverlay(
              strings: game.strings,
              logo: game.theme.logo,
              onStart: g.start,
              onClose: _close,
            ),
            GameOverlays.hud: (context, g) => HudOverlay(
              hud: game.hudFor(context, g),
              pauseLabel: game.strings.pause,
              onPause: g.pause,
            ),
            GameOverlays.pause: (_, g) => PauseOverlay(
              strings: game.strings,
              onResume: g.resume,
              onClose: _close,
            ),
            GameOverlays.gameOver: (_, g) => GameOverOverlay(
              strings: game.strings,
              score: g.score.value,
              onPlayAgain: g.start,
              onClose: _close,
            ),
          },
        ),
      ),
    );
  }
}
