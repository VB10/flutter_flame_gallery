import 'package:flame_gallery_core/src/model/game_asset.dart';
import 'package:flutter/widgets.dart';

/// What is drawn behind the playfield. One model for every game.
@immutable
sealed class GameBackground {
  const GameBackground();

  const factory GameBackground.color(Color color) = ColorBackground;
  const factory GameBackground.gradient(Gradient gradient) = GradientBackground;
  const factory GameBackground.image(GameAsset asset, {BoxFit fit}) =
      ImageBackground;

  /// Builds the widget drawn behind the game canvas.
  Widget build(BuildContext context);
}

final class ColorBackground extends GameBackground {
  const ColorBackground(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) => ColoredBox(color: color);
}

final class GradientBackground extends GameBackground {
  const GradientBackground(this.gradient);

  final Gradient gradient;

  @override
  Widget build(BuildContext context) =>
      DecoratedBox(decoration: BoxDecoration(gradient: gradient));
}

final class ImageBackground extends GameBackground {
  const ImageBackground(this.asset, {this.fit = BoxFit.cover});

  final GameAsset asset;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) => SizedBox.expand(
    child: Image.asset(
      asset.path,
      package: asset.package,
      fit: fit,
      gaplessPlayback: true,
    ),
  );
}
