# flame_gallery example

```dart
import 'package:flame_gallery/flame_gallery.dart';
import 'package:flutter/material.dart';

Future<void> playCampaign(BuildContext context) async {
  final result = await FlameGallery.show(
    context,
    game: FruitSlice(
      config: const SliceConfig(timeLimit: Duration(seconds: 30), bomb: null),
      strings: FruitSlice.stringsTr,
    ),
    onEvent: (event) => debugPrint('$event'),
  );
  if (result != null && result.score >= 50) {
    // Grant the coupon.
  }
}
```

A full demo app with every game lives in
[apps/example](https://github.com/VB10/flame_gallery/tree/main/apps/example).
