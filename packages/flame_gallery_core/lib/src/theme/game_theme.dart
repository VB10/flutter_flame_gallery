import 'package:flame_gallery_core/src/theme/game_background.dart';
import 'package:flutter/material.dart';

/// Brand customisation for a game. Every field is optional: anything left
/// `null` falls back to the host app's [Theme].
@immutable
final class GameTheme {
  const GameTheme({
    this.colorScheme,
    this.fontFamily,
    this.logo,
    this.background,
    this.themeData,
  });

  final ColorScheme? colorScheme;
  final String? fontFamily;

  /// Shown on the start panel.
  final ImageProvider? logo;

  /// Drawn behind the playfield of every game. `null` keeps the
  /// [ColorScheme.surface] fill.
  final GameBackground? background;

  /// Full control over the menu look (buttons, text, cards). Its
  /// [ThemeData.colorScheme] also drives the in-game colors unless
  /// [colorScheme] is given. [fontFamily] is applied on top.
  final ThemeData? themeData;

  ColorScheme resolveColors(BuildContext context) =>
      colorScheme ?? themeData?.colorScheme ?? Theme.of(context).colorScheme;

  ThemeData toThemeData(BuildContext context) {
    final font = fontFamily;
    final base = themeData;
    if (base == null) {
      return ThemeData(colorScheme: resolveColors(context), fontFamily: font);
    }
    final scheme = colorScheme;
    final themed = scheme == null ? base : base.copyWith(colorScheme: scheme);
    return font == null
        ? themed
        : themed.copyWith(
            textTheme: themed.textTheme.apply(fontFamily: font),
            primaryTextTheme: themed.primaryTextTheme.apply(fontFamily: font),
          );
  }

  /// Nullable fields take a [ValueGetter] so they can also be cleared:
  /// `copyWith(logo: () => null)` removes the logo, omitting it keeps it.
  GameTheme copyWith({
    ValueGetter<ColorScheme?>? colorScheme,
    ValueGetter<String?>? fontFamily,
    ValueGetter<ImageProvider?>? logo,
    ValueGetter<GameBackground?>? background,
    ValueGetter<ThemeData?>? themeData,
  }) => GameTheme(
    colorScheme: colorScheme == null ? this.colorScheme : colorScheme(),
    fontFamily: fontFamily == null ? this.fontFamily : fontFamily(),
    logo: logo == null ? this.logo : logo(),
    background: background == null ? this.background : background(),
    themeData: themeData == null ? this.themeData : themeData(),
  );
}
