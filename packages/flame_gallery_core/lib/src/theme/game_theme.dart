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

  /// Nullable fields take a [ValueGetter] so they can also be cleared:
  /// `copyWith(logo: () => null)` removes the logo, omitting it keeps it.
  GameTheme copyWith({
    ValueGetter<ColorScheme?>? colorScheme,
    ValueGetter<String?>? fontFamily,
    ValueGetter<ImageProvider?>? logo,
  }) => GameTheme(
    colorScheme: colorScheme == null ? this.colorScheme : colorScheme(),
    fontFamily: fontFamily == null ? this.fontFamily : fontFamily(),
    logo: logo == null ? this.logo : logo(),
  );
}
