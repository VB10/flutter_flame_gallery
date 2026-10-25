import 'package:flame_gallery/flame_gallery.dart';
import 'package:flame_gallery_example/app/maestro_keys.dart';
import 'package:flame_gallery_example/features/gallery_home/model/demo_entry.dart';
import 'package:flutter/material.dart';

final class GalleryHomeView extends StatefulWidget {
  const GalleryHomeView({super.key});

  @override
  State<GalleryHomeView> createState() => _GalleryHomeViewState();
}

final class _GalleryHomeViewState extends State<GalleryHomeView> {
  GameResult? _lastResult;

  Future<void> _open(DemoEntry entry) async {
    final result = await FlameGallery.show(
      context,
      game: entry.game,
      onEvent: (event) => debugPrint('[FlameGallery] $event'),
    );
    if (!mounted) return;
    setState(() => _lastResult = result);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Flame Gallery')),
    body: Semantics(
      identifier: MaestroKeys.home.view,
      container: true,
      child: ListView(
        padding: const EdgeInsets.all(GallerySpacing.md),
        children: [
          if (_lastResult case final result?) ...[
            _ResultCard(result: result),
            const SizedBox(height: GallerySpacing.sm),
          ],
          for (final entry in DemoEntry.all)
            Padding(
              padding: const EdgeInsets.only(bottom: GallerySpacing.sm),
              child: _DemoCard(entry: entry, onTap: () => _open(entry)),
            ),
        ],
      ),
    ),
  );
}

final class _DemoCard extends StatelessWidget {
  const _DemoCard({required this.entry, required this.onTap});

  final DemoEntry entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    identifier: MaestroKeys.home.demoCard(entry.id),
    child: Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        leading: Icon(entry.icon),
        title: Text(entry.title),
        subtitle: Text(entry.subtitle),
        trailing: const Icon(Icons.play_arrow_rounded),
        onTap: onTap,
      ),
    ),
  );
}

final class _ResultCard extends StatelessWidget {
  const _ResultCard({required this.result});

  final GameResult result;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const keys = MaestroKeys.home;
    return Semantics(
      identifier: keys.resultCard,
      container: true,
      child: Card.filled(
        child: Padding(
          padding: const EdgeInsets.all(GallerySpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Last result', style: textTheme.titleMedium),
              const SizedBox(height: GallerySpacing.sm),
              _ResultField(
                id: keys.resultGame,
                label: 'Game',
                value: result.gameId,
              ),
              _ResultField(
                id: keys.resultScore,
                label: 'Score',
                value: '${result.score}',
              ),
              _ResultField(
                id: keys.resultReason,
                label: 'Reason',
                value: result.reason.name,
              ),
              _ResultField(
                id: keys.resultEndedBy,
                label: 'Ended by',
                value: '${result.stats[GameStatKeys.endedBy] ?? '-'}',
              ),
              Text('Play time: ${result.playTime.inSeconds}s'),
              Text('Stats: ${result.stats}', style: textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Label: value" row whose semantics label is just [value], so UI tests can
/// assert `id + text` without parsing.
final class _ResultField extends StatelessWidget {
  const _ResultField({
    required this.id,
    required this.label,
    required this.value,
  });

  final String id;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Semantics(
    identifier: id,
    container: true,
    label: value,
    excludeSemantics: true,
    child: Text('$label: $value'),
  );
}
