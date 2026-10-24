import 'package:flame/components.dart';
import 'package:flame_gallery_runner/src/config/runner_difficulty.dart';
import 'package:flame_gallery_runner/src/game/runner_game.dart';
import 'package:flame_gallery_runner/src/logic/obstacle_row_planner.dart';

/// Spawns a new row each time the track has scrolled one row spacing.
final class RowSpawner extends Component with HasGameReference<RunnerGame> {
  RowSpawner({required this.difficulty, required this.planner});

  /// Empty run-up before the first row, in screen heights.
  static const _firstRowDelay = 0.6;

  final RunnerDifficulty difficulty;
  final ObstacleRowPlanner planner;
  double _untilNextRow = 0;

  void reset() => _untilNextRow = _firstRowDelay * game.size.y;

  @override
  void update(double dt) {
    if (!game.isPlaying) return;
    _untilNextRow -= game.speed * dt;
    if (_untilNextRow > 0) return;
    _untilNextRow += difficulty.rowSpacing * game.size.y;
    game.spawnRow(planner.plan());
  }
}
