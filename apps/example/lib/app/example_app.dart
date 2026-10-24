import 'package:flame_gallery_example/features/gallery_home/view/gallery_home_view.dart';
import 'package:flutter/material.dart';

final class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  static const _seed = Color(0xFF5B5BD6);

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Flame Gallery',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(colorSchemeSeed: _seed),
    darkTheme: ThemeData(colorSchemeSeed: _seed, brightness: Brightness.dark),
    home: const GalleryHomeView(),
  );
}
