part of '../game_host_page.dart';

final class _PauseHost extends StatelessWidget {
  const _PauseHost({required this.host, required this.game});

  final _GameHostPageState host;
  final GalleryFlameGame game;

  @override
  Widget build(BuildContext context) {
    final strings = host.widget.game.strings;
    return host.widget.overlays.pause?.call(
          context,
          host._uiFor(game, context),
        ) ??
        PauseOverlay(
          strings: strings,
          onResume: game.resume,
          onClose: host._close,
        );
  }
}
