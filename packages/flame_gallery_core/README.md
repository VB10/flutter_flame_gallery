# flame_gallery_core

Shared foundation of [Flame Gallery](https://pub.dev/packages/flame_gallery): the game contract, the full screen host page with start / pause / game over menus, theming, texts, results and HUD widgets.

You need this package directly only to **build your own gallery game**; to use the existing games depend on [`flame_gallery`](https://pub.dev/packages/flame_gallery).

## What is inside

| Type | Role |
|---|---|
| `GalleryGame<G>` | Immutable public description of a game (config, `GameTheme`, `GameStrings`). Creates a fresh `G` per session and builds its HUD. |
| `GalleryFlameGame` | Base `FlameGame`: phase machine (ready → playing ⇄ paused → over), score, overlays, event stream, auto pause on app background, engine pause after game over. |
| `GameHostPage` | Hosts a `GalleryGame` full screen (route body or embedded); handles back button, immersive mode and closing with a `GameResult`. |
| `GameTheme`, `GameStrings` | Brand colors / font / logo and every menu text (English, Turkish, `copyWith`). |
| `GameAsset` | Asset path + optional package, for sprites from the app or a game package. |
| `GameResult`, `GameEvent` | What the host app receives. |
| `HudChip`, `HudValueChip`, `HudLivesChip` | HUD building blocks. |
| `GalleryKeys` | `Semantics` identifiers for UI tests. |

See the [example](example/example.md) for a minimal custom game.

## License

MIT
