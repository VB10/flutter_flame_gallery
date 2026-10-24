# Flame Gallery example

Demo host app for [Flame Gallery](../../README.md): every game with its default
config plus branded, timed and seeded variants. Runs on iOS, Android and web
(the web build is the [online playground](https://vb10.github.io/flutter_flame_gallery/play/)).

```bash
flutter run                       # from this folder, or F5 in VS Code
flutter build web --release       # playground build
```

| Path | What |
|---|---|
| `lib/features/gallery_home/model/demo_entry.dart` | The demo list: each entry is one `GalleryGame` with its config |
| `lib/features/gallery_home/view/gallery_home_view.dart` | Opens a game with `FlameGallery.show` and shows the last `GameResult` |
| `lib/features/gallery_home/service/asset_rhythm_audio.dart` | `RhythmAudio` for Note Rush on top of `flame_audio` |
| `lib/app/maestro_keys.dart` | `Semantics` identifiers used by the UI tests |
| `assets/audio/note_rush_demo.mp3` | Synthesised demo track matching `RhythmSong.demo` |
| `maestro/` | Maestro smoke suite (`run_maestro_test.sh`, `PLATFORM=ios\|android`) |

`flame_audio` is a dependency of this app only; the library packages stay
audio-free.
