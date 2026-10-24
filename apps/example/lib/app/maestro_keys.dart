import 'package:flutter/foundation.dart';

/// `Semantics.identifier`s of the example app screens. Mirrored in
/// `maestro/flows/core/keys.js`; keep both in sync.
abstract final class MaestroKeys {
  static const home = _Home();
}

@immutable
final class _Home {
  const _Home();

  String get view => 'home_view';
  String get resultCard => 'last_result_card';
  String get resultGame => 'last_result_game';
  String get resultScore => 'last_result_score';
  String get resultReason => 'last_result_reason';
  String get resultEndedBy => 'last_result_ended_by';

  String demoCard(String demoId) => 'demo_card_$demoId';
}
