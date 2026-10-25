part of '../game_host_page.dart';

mixin _GameHostPageMixin on State<GameHostPage> {
  GalleryFlameGame? _flameGame;
  StreamSubscription<GameEvent>? _subscription;

  GalleryFlameGame get flameGame => _flameGame!;

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
    final flameGame =
        widget.game.createGame(widget.game.theme.resolveColors(context))
          ..configure(
            sounds: widget.sounds,
            hasBackdrop: widget.game.theme.background != null,
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

  GameUi _uiFor(GalleryFlameGame g, BuildContext context) => GameUi(
    strings: widget.game.strings,
    score: g.score,
    phase: g.phase,
    result: () => g.result,
    logo: widget.game.theme.logo,
    hud: widget.game.hudFor(context, g),
    start: g.start,
    pause: g.pause,
    resume: g.resume,
    close: _close,
  );
}
