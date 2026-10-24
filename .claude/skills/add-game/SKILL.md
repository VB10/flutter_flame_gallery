---
name: add-game
description: Scaffolds a new mini game package (packages/flame_gallery_<name>) in Flame Gallery, wires it into the workspace, the flame_gallery facade and the example app. Use when the user says "yeni oyun ekle", "add a game", "runner oyununu başlat", "flame_gallery_xxx paketi oluştur" or names a new game to build.
---

# add-game

Creates `packages/flame_gallery_<name>` following the same shape as `packages/flame_gallery_slice` (the reference implementation — read it before writing anything).

## Inputs (ask only if missing)

- `name`: snake_case package suffix, e.g. `runner` → `flame_gallery_runner`.
- Public class name, e.g. `EndlessRunner` (must not be a trademark: no "Temple Run", "Subway Surfers"...).
- One-line mechanic + end conditions (time? lives? distance?).

## Steps

1. **Read** `CLAUDE.md` and `packages/flame_gallery_slice/` (pubspec, `lib/flame_gallery_slice.dart`, `src/fruit_slice.dart`, `src/game/slice_game.dart`, one component, one test).

2. **Create the package**
   ```
   packages/flame_gallery_<name>/
     pubspec.yaml            copy flame_gallery_slice's; change name/description; keep `resolution: workspace`
     analysis_options.yaml   include: ../../analysis_options.yaml
     assets/images/          placeholder sprites
     lib/flame_gallery_<name>.dart    exports: config, items, the GalleryGame, end-cause enum
     lib/src/<public_name>.dart          final class X extends GalleryGame<XGame>
     lib/src/config/<name>_config.dart   immutable, all fields defaulted, copyWith
     lib/src/logic/                      pure Dart rules (no Flame components)
     lib/src/component/                  one Flame component per file
     lib/src/game/<name>_game.dart       final class XGame extends GalleryFlameGame
     lib/src/view/<name>_hud.dart        HUD from ValueNotifiers + HudChip
     test/                               logic tests + flame_test flow tests
   ```
   The game class must: take `config`, `colors`, `gameId`, optional `math.Random`; set `images = Images(prefix: '')`; implement `onRoundStart`; end via `finish()`; expose an end-cause in `collectStats()['endedBy']`; dispose its notifiers in `onRemove`.

   Default strings: `static const stringsEn = GameStrings.en(...)` and `stringsTr = GameStrings.tr(...)`.

3. **Sprites**: generate IP-clean placeholders with Pillow in the scratchpad (venv, `python -I`), 256×256 transparent PNG, like `flame_gallery_slice/assets/images`. Never download art.

4. **Wire it up**
   - Root `pubspec.yaml` → add `packages/flame_gallery_<name>` under `workspace:`.
   - `packages/flame_gallery/pubspec.yaml` → path dependency; `lib/flame_gallery.dart` → `export 'package:flame_gallery_<name>/flame_gallery_<name>.dart';`
   - `apps/example/lib/features/gallery_home/model/demo_entry.dart` → add a `DemoEntry` (default) and, if useful, a branded variant.

   - Publishing files: README, CHANGELOG, LICENSE, `example/example.md`, pubspec metadata (copy from `flame_gallery_slice`), a screenshot in `packages/flame_gallery/screenshots/` + pubspec `screenshots:` entry, a row in both READMEs and `site/index.html`.
   - E2E: game specific HUD ids in `lib/src/testing/<name>_keys.dart`, mirrored in `apps/example/maestro/core/keys.js`; a flow under `maestro/flows/<name>/` + suite; add it to `smoke_test.yaml`; add the publish job to `.github/workflows/publish.yml` and the dry-run matrix in `ci.yml`.

5. **Verify**: `flutter pub get` at root, then `melos run analyze` and `melos run test`. Fix until clean. Optionally run the example on a simulator and screenshot the game.

6. **Review**: dispatch the `architecture-reviewer` agent on the new package and address blockers.

## Don'ts

- No dependency on another `flame_gallery_<game>` package; shared needs go to `flame_gallery_core` (and justify it).
- No bloc/riverpod/freezed/get_it.
- Don't change `flame_gallery_core` contracts in the same step unless the new game truly needs it — if so, call it out to the user as an API change.
