part of '../game_host_page.dart';

final class _GameOverHost extends StatelessWidget {
  const _GameOverHost({required this.host, required this.game});

  final _GameHostPageState host;
  final GalleryFlameGame game;

  @override
  Widget build(BuildContext context) {
    final strings = host.widget.game.strings;
    return host.widget.overlays.gameOver?.call(
          context,
          host._uiFor(game, context),
        ) ??
        GameOverOverlay(
          strings: strings,
          score: game.score.value,
          onPlayAgain: game.start,
          onClose: host._close,
        );
  }
}
