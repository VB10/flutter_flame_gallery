part of '../game_host_page.dart';

final class _StartHost extends StatelessWidget {
  const _StartHost({required this.host, required this.game});

  final _GameHostPageState host;
  final GalleryFlameGame game;

  @override
  Widget build(BuildContext context) {
    final strings = host.widget.game.strings;
    return host.widget.overlays.start?.call(
          context,
          host._uiFor(game, context),
        ) ??
        StartOverlay(
          strings: strings,
          logo: host.widget.game.theme.logo,
          onStart: game.start,
          onClose: host._close,
        );
  }
}
