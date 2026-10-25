part of '../game_host_page.dart';

final class _HudHost extends StatelessWidget {
  const _HudHost({required this.host, required this.game});

  final _GameHostPageState host;
  final GalleryFlameGame game;

  @override
  Widget build(BuildContext context) {
    final strings = host.widget.game.strings;
    return host.widget.overlays.hud?.call(
          context,
          host._uiFor(game, context),
        ) ??
        HudOverlay(
          hud: host.widget.game.hudFor(context, game),
          pauseLabel: strings.pause,
          onPause: game.pause,
        );
  }
}
