import 'dart:math' as math;

import 'package:flutter/foundation.dart';

/// Exact length in seconds, for frame-time math.
extension DurationSeconds on Duration {
  double get asSeconds => inMicroseconds / Duration.microsecondsPerSecond;
}

/// Counts a round's time limit down and publishes the whole seconds left.
///
/// A `null` [limit] means the round has no timer: [secondsLeft] stays `null`
/// and [tick] never expires. Call [reset] on round start, [tick] while
/// playing and [dispose] in `onRemove`.
final class RoundCountdown {
  RoundCountdown(this.limit)
    : _remaining = limit?.asSeconds ?? 0,
      _secondsLeft = ValueNotifier<int?>(_wholeSeconds(limit?.asSeconds));

  final Duration? limit;
  final ValueNotifier<int?> _secondsLeft;
  double _remaining;

  ValueListenable<int?> get secondsLeft => _secondsLeft;

  void reset() {
    _remaining = limit?.asSeconds ?? 0;
    _secondsLeft.value = _wholeSeconds(limit?.asSeconds);
  }

  /// Advances by [dt] seconds. Returns `true` only on the tick that runs out.
  bool tick(double dt) {
    if (limit == null || _remaining <= 0) return false;
    _remaining -= dt;
    _secondsLeft.value = _wholeSeconds(_remaining);
    return _remaining <= 0;
  }

  void dispose() => _secondsLeft.dispose();

  static int? _wholeSeconds(double? seconds) =>
      seconds == null ? null : math.max(0, seconds.ceil());
}
