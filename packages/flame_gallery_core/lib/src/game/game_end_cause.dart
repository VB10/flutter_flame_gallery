import 'package:flame_gallery_core/src/game/gallery_flame_game.dart';
import 'package:flame_gallery_core/src/model/game_result.dart';
import 'package:flame_gallery_core/src/model/game_stat_keys.dart';
import 'package:flutter/foundation.dart';

/// Remembers why a round ended and reports it as [GameStatKeys.endedBy].
///
/// Games end rounds with [finishWith] instead of `finish()`. A round closed
/// by the host (no cause) reports `quit`. Subclasses that override
/// `collectStats` spread `super.collectStats()` to keep the cause.
base mixin GameEndCause<C extends Enum> on GalleryFlameGame {
  C? _endCause;

  /// Why the last round ended; `null` while playing or after a quit.
  C? get endCause => _endCause;

  @protected
  void finishWith(C cause) {
    _endCause = cause;
    finish();
  }

  @override
  void start() {
    _endCause = null;
    super.start();
  }

  @override
  Map<String, Object> collectStats() => {
    ...super.collectStats(),
    GameStatKeys.endedBy: _endCause?.name ?? GameEndReason.quit.name,
  };
}
