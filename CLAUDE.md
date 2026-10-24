# CLAUDE.md

Guidance for Claude Code when working in this repository.

## What this is

**Flame Gallery** — a library of drop-in 2D mini games (Fruit Slice, later Runner, Rhythm…) built on Flutter + Flame. A host app adds one dependency and calls:

```dart
final result = await FlameGallery.show(context, game: const FruitSlice());
```

Companies customise each game (colors, logo, texts, sprites, rules) without touching game code. Native iOS/Android hosts will embed it through Flutter add-to-app (planned `flame_gallery_native`).

## Commands

Pub workspace (root `pubspec.yaml`) + Melos 8 (config under the `melos:` key).

```bash
flutter pub get            # resolves the whole workspace
melos run analyze          # flutter analyze in every package
melos run test             # flutter test where test/ exists
melos run format           # dart format
cd apps/example && flutter run
melos run e2e:ios          # Maestro smoke suite (DEVICE=<udid> optional)
melos run e2e:android      # same on an emulator; build+install the app first
```

## Layout

```
packages/
  flame_gallery_core/    contracts + host + shared overlays. Depends on flame only.
  flame_gallery_<name>/     one package per game. Depends on flame_gallery_core + flame only.
                   flame_gallery_slice (FruitSlice), flame_gallery_runner (EndlessRunner),
                   flame_gallery_match (SweetSwap), flame_gallery_rhythm (NoteRush)
  flame_gallery/   facade: FlameGallery.show + re-exports core and all games.
apps/example/      demo host app (iOS, Android, web; lib/app, lib/features/<feature>/{model,service,view}) + maestro/.
site/              GitHub Pages landing page (pages.yml adds the web demo under /play/).
marketing/         promo.mp4, poster.png, og.png — rebuilt by tool/promo/make_promo.py.
.github/workflows/ ci.yml (format, analyze, test, publish dry-run, web build), publish.yml (per package tags), pages.yml.
```

### Dependency rules (enforced in review)

- `flame_gallery_core` → `flame`, `flutter`. Nothing else.
- `flame_gallery_<game>` → `flame_gallery_core`, `flame`, `flutter`. **Never** another game, **never** `flame_gallery`.
- `flame_gallery` → `flame_gallery_core` + every `flame_gallery_<game>`. No logic beyond `FlameGallery`.
- No state-management / codegen packages (bloc, riverpod, freezed, get_it) in library packages: host apps must not inherit our dependency choices. Use `ValueNotifier` + immutable classes.
- New third-party dependency in a library package = explicit decision, written down here with the reason.
- Audio stays out of library packages: Note Rush takes a `RhythmAudio` interface. The example app implements it with `flame_audio` (example-only dependency).
- Internal dependencies use hosted constraints (`flame_gallery_core: ^0.1.0`); the pub workspace resolves them locally. Bump them together with versions.

## Core contracts (flame_gallery_core)

| Type | Role |
|---|---|
| `GalleryGame<G>` | Immutable public description (config + `GameTheme` + `GameStrings`). `createGame(colors)` builds a fresh Flame game per session; `buildHud` returns the in-game HUD. |
| `GalleryFlameGame` | Base `FlameGame` (`abstract base class`). Owns phase machine `ready → playing ⇄ paused → over`, read-only `score`/`phase` (`ValueListenable`), overlay switching and a **synchronous** broadcast `events` stream. Subclasses implement `onRoundStart()`, call `addScore()` / `finish()`, optionally `collectStats()`. `quit()` ends without the game-over panel (host close, and automatically in `onRemove`). |
| `GameHostPage` | Builds the `GameWidget`, the shared overlays (start / hud / pause / game over), handles back button and app background (auto pause). |
| `GameTheme` | Optional `ColorScheme`, font, logo. No scheme → host `Theme` kept as is (font swapped if given). With a scheme → a fresh `ThemeData` so text/component colors match the brand brightness. |
| `GameStrings` | All overlay texts; `GameStrings.en/.tr` + `copyWith`. |
| `GameAsset` | Asset path + optional package → bundle `key`. Games load images with `Images(prefix: '')` and `asset.key` (never mutate the global `Flame.images`). |
| `GameResult` / `GameEvent` | What the host receives. `GameResult.toJson()` is the future platform channel payload. |

## Game package structure

```
packages/flame_gallery_<name>/lib/
  flame_gallery_<name>.dart              public exports only (config, item types, the GalleryGame)
  src/<name>_game.dart          (or src/<public_name>.dart) the GalleryGame subclass
  src/config/                   immutable config, item definitions, difficulty enum
  src/logic/                    pure Dart rules/math, NO Flame components → unit tested
  src/component/                Flame components (one per file)
  src/game/<name>_game.dart     the GalleryFlameGame subclass (orchestration only)
  src/view/                     Flutter HUD widgets
assets/images/                  placeholder sprites (generated, IP-clean)
test/                           logic tests + flame_test game tests
```

Use the `add-game` skill (`.claude/skills/add-game`) to scaffold a new game.

## Code rules

- `final class` for every concrete class; `abstract base class` / `abstract interface class` for contracts; `sealed` for event/state families.
- `const` wherever possible; trailing commas; expression bodies for one-liners; cascades.
- Flutter UI: colors only from `Theme.of(context).colorScheme` (the host page wraps games in a `Theme` built from `GameTheme`); spacing/radius from `GallerySpacing`, `GalleryRadius`, `GallerySizes`; `ColoredBox`/`DecoratedBox` instead of `Container`; extract widgets past ~50 lines.
- Flame code: tuning numbers live as named `static const` on the owning class or in the difficulty enum — no bare magic numbers in `update`.
- Gameplay checks `isPlaying` before scoring/penalising; only `GalleryFlameGame` changes phase.
- Fast-moving games clamp the simulated step (`runner`: `_maxStep = 1/30`) so a jank frame cannot tunnel objects through hit windows; Flame does not cap `dt`.
- `GameHostPage` runs games in `SystemUiMode.immersiveSticky` (restores `edgeToEdge`; `FlameGallery.show(immersive: false)` opts out) and the engine pauses 0.8s after game over (battery; also lets UI tests see an idle screen).
- Turn/animation-based games (match) never end mid-animation: end conditions that fire while busy are deferred to the settle stage so no awarded points are lost.
- Every `ValueNotifier` a game creates is disposed in `onRemove`.
- Minimal comments: public API docs + non-obvious math only.
- Lints: `very_good_analysis` 11 + root `analysis_options.yaml`. Disabled on purpose: `unnecessary_type_name_in_constructor` (keep classic constructors, like Coverz), `discarded_futures` (Flame `add()` returns `FutureOr`).
- Done = `melos run analyze` clean + `melos run test` green.

## Testing

- `src/logic/` → plain `test`.
- Game flow → `flame_test` `testWithGame`. Tests must register overlay entries (`game.overlays.addEntry(name, …)` for `GameOverlays.all`) because no `GameWidget` exists, and call `TestWidgetsFlutterBinding.ensureInitialized()` when assets load.
- Inject `math.Random(seed)` for deterministic spawns.

## E2E (Maestro)

`apps/example/maestro/`: `suites/smoke_test.yaml` → `suites/sub/*` → `flows/<game>/*_flow.yaml` (+ `*_setup.js` expected values), shared `core/keys.js` (all ids) and `core/flows_core.js` (timeouts). Flows never hardcode ids/values; everything comes from `output.*`.

- Selectors are `Semantics(identifier:)`: overlays/HUD → `GalleryKeys` (flame_gallery_core), game specific HUD → `RunnerKeys` / `MatchKeys`, example screens → `apps/example/lib/app/maestro_keys.dart`. Keep `core/keys.js` in sync.
- A running Flame game never reports an idle UI, and every element lookup waits for idle: ~1–3s on iOS, ~10s on Android (UiAutomator). So pause before asserting HUD during play, keep in-game element taps to a minimum, use `waitToSettleTimeoutMs: 200` (literal number; `${}` not allowed there), and gate pause-dependent checks to iOS for games that can end in seconds (runner).
- Deterministic gameplay: `MatchConfig(seed:)` (Daily demo). Swap coordinates in `sweet_swap_setup.js` are screen percentages (integers only) — verified on iPhone 17 and Pixel 7a.
- Android: swipes must start inside ~12–88% width (edge = system back gesture: pause, then close). First immersive entry shows a one-time "Viewing full screen" hint; `core/dismiss_system_hints.yaml` taps it away.
- Reports: `apps/example/maestro/build/maestro-<platform>/report.xml` (JUnit) + failure screenshots in `artifacts/`.

## Publishing

Package names are `flame_gallery*` (all MIT, repo github.com/VB10/flame_gallery). Every package needs README, CHANGELOG, LICENSE, `example/example.md`; the facade carries the pub.dev gallery (`screenshots:` in its pubspec). Order: core → games → facade. First versions by hand (`flutter pub publish`), later via tags `<package>-v<version>` (publish.yml, OIDC). `flutter pub publish --dry-run` must report 0 warnings; the repo must be a git repo or `build/` leaks into the archive.

## IP

Mechanics are free; names and art are not. Never use "Fruit Ninja", "Temple Run", "Piano Tiles" etc. in code, assets or store text. Sprites are generated placeholders.
