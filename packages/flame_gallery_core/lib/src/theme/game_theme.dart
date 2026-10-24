import 'package:flutter/material.dart';

/// Brand customisation for a game. Every field is optional: anything left
/// `null` falls back to the host app's [Theme].
@immutable
final class GameTheme {
  const GameTheme({this.colorScheme, this.fontFamily, this.logo});

  final ColorScheme? colorScheme;
  final String? fontFamily;

  /// Shown on the start panel.
  final ImageProvider? logo;

  ColorScheme resolveColors(BuildContext context) =>
      colorScheme ?? Theme.of(context).colorScheme;

  ThemeData toThemeData(BuildContext context) =>
      ThemeData(colorScheme: resolveColors(context), fontFamily: fontFamily);

  GameTheme copyWith({
    ColorScheme? colorScheme,
    String? fontFamily,
    ImageProvider? logo,
  }) => GameTheme(
    colorScheme: colorScheme ?? this.colorScheme,
    fontFamily: fontFamily ?? this.fontFamily,
    logo: logo ?? this.logo,
  );
}
