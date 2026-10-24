import 'package:flame_gallery/flame_gallery.dart';
import 'package:flame_gallery_example/features/gallery_home/service/asset_rhythm_audio.dart';
import 'package:flutter/material.dart';

/// One card on the demo home screen.
@immutable
final class DemoEntry {
  const DemoEntry({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.game,
  });

  /// Stable id used for the card's test identifier.
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final GalleryGame game;

  static final List<DemoEntry> all = [
    const DemoEntry(
      id: 'fruit_slice',
      title: 'Fruit Slice',
      subtitle: 'Default config: 60s timer, bombs on',
      icon: Icons.restaurant_rounded,
      game: FruitSlice(),
    ),
    const DemoEntry(
      id: 'fruit_slice_survival',
      title: 'Fruit Slice · Survival',
      subtitle: 'No timer, 3 lives, hard',
      icon: Icons.favorite_rounded,
      game: FruitSlice(
        config: SliceConfig(
          timeLimit: null,
          lives: 3,
          difficulty: SliceDifficulty.hard,
        ),
      ),
    ),
    DemoEntry(
      id: 'fruit_slice_brand',
      title: 'Meyve Kes · Brand demo',
      subtitle: 'Custom colors, Turkish texts, 30s, no bombs, easy',
      icon: Icons.storefront_rounded,
      game: FruitSlice(
        strings: FruitSlice.stringsTr.copyWith(
          title: 'Yaz Kampanyası',
          instructions: '30 saniyede en çok meyveyi kes, kuponu kap!',
        ),
        theme: GameTheme(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00897B),
            brightness: Brightness.dark,
          ),
        ),
        config: const SliceConfig(
          timeLimit: Duration(seconds: 30),
          bomb: null,
          difficulty: SliceDifficulty.easy,
        ),
      ),
    ),
    const DemoEntry(
      id: 'runner',
      title: 'Ruins Runner',
      subtitle: 'Endless 3-lane runner, 1 life',
      icon: Icons.directions_run_rounded,
      game: EndlessRunner(),
    ),
    const DemoEntry(
      id: 'runner_timed',
      title: 'Harabe Koşusu · 60s',
      subtitle: 'Turkish texts, 60s timer, 3 lives, easy',
      icon: Icons.timer_rounded,
      game: EndlessRunner(
        strings: EndlessRunner.stringsTr,
        config: RunnerConfig(
          timeLimit: Duration(seconds: 60),
          lives: 3,
          difficulty: RunnerDifficulty.easy,
        ),
      ),
    ),
    const DemoEntry(
      id: 'sweet_swap',
      title: 'Sweet Swap',
      subtitle: 'Match-3, 8×8 board, 20 moves',
      icon: Icons.grid_view_rounded,
      game: SweetSwap(),
    ),
    const DemoEntry(
      id: 'sweet_swap_target',
      title: 'Şeker Eşle · Hedef',
      subtitle: 'Turkish texts, 7×7, 15 moves, target 800',
      icon: Icons.flag_rounded,
      game: SweetSwap(
        strings: SweetSwap.stringsTr,
        config: MatchConfig(
          rows: 7,
          columns: 7,
          moveLimit: 15,
          targetScore: 800,
        ),
      ),
    ),
    const DemoEntry(
      id: 'sweet_swap_daily',
      title: 'Sweet Swap · Daily',
      subtitle: 'Seeded board: same puzzle for every player',
      icon: Icons.today_rounded,
      game: SweetSwap(config: MatchConfig(seed: dailySeed)),
    ),
    DemoEntry(
      id: 'note_rush',
      title: 'Note Rush',
      subtitle: 'Rhythm, 4 lanes, synthesised demo track (34s)',
      icon: Icons.music_note_rounded,
      game: NoteRush(audio: AssetRhythmAudio(demoSong)),
    ),
    DemoEntry(
      id: 'note_rush_hard',
      title: 'Nota Yakala · Zor',
      subtitle: 'Turkish texts, hard, 10 misses allowed',
      icon: Icons.graphic_eq_rounded,
      game: NoteRush(
        audio: AssetRhythmAudio(demoSong),
        strings: NoteRush.stringsTr,
        labels: RhythmLabels.tr,
        config: const RhythmConfig(
          difficulty: RhythmDifficulty.hard,
          missLimit: 10,
        ),
      ),
    ),
  ];

  /// Matches `RhythmSong.demo` (120 BPM, 2 s lead-in, 64 beats).
  static const demoSong = 'audio/note_rush_demo.mp3';

  /// Fixed so the daily demo (and its Maestro flow) always gets one board.
  static const dailySeed = 20261024;
}
