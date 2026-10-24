import 'package:flutter/foundation.dart';

/// Points at an image bundled either by the host app or by a game package.
@immutable
final class GameAsset {
  const GameAsset(this.path, {this.package});

  /// Path inside the owning package, e.g. `assets/images/apple.png`.
  final String path;

  /// Owning package. `null` means the host app's own bundle.
  final String? package;

  /// Asset bundle key used to load the file.
  String get key => package == null ? path : 'packages/$package/$path';

  @override
  bool operator ==(Object other) =>
      other is GameAsset && other.path == path && other.package == package;

  @override
  int get hashCode => Object.hash(path, package);

  @override
  String toString() => 'GameAsset($key)';
}
