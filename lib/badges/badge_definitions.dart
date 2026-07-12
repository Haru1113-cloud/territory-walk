// このファイルの役割:
// バッジの一覧と、それぞれの達成条件を定義する。
// 「今の実績が条件を満たすか」の判定はここに集約し、Controllerは
// 集計済みのWalkStatsを渡して結果を受け取るだけにする。

import 'package:flutter/material.dart';

import 'badge.dart';

/// バッジの達成条件判定に必要な集計値。散歩記録・領土の実データから
/// Controllerが都度計算して渡す(値そのものは保存しない)。
class WalkStats {
  final int totalWalks;
  final int totalTerritories;
  final double totalDistanceMeters;
  final int distinctWalkDays;

  const WalkStats({
    required this.totalWalks,
    required this.totalTerritories,
    required this.totalDistanceMeters,
    required this.distinctWalkDays,
  });
}

class _Badge {
  final BadgeDefinition definition;
  final bool Function(WalkStats stats) isAchieved;

  const _Badge(this.definition, this.isAchieved);
}

final List<_Badge> _badges = [
  _Badge(
    const BadgeDefinition(
      id: 'first_walk',
      title: '最初の一歩',
      description: '初めての散歩を完了した',
      icon: Icons.directions_walk,
    ),
    (stats) => stats.totalWalks >= 1,
  ),
  _Badge(
    const BadgeDefinition(
      id: 'first_territory',
      title: '初めての領土',
      description: '初めて輪を閉じて領土を確定した',
      icon: Icons.flag,
    ),
    (stats) => stats.totalTerritories >= 1,
  ),
  _Badge(
    const BadgeDefinition(
      id: 'distance_5km',
      title: '5kmウォーカー',
      description: '累計の移動距離が5kmを超えた',
      icon: Icons.social_distance,
    ),
    (stats) => stats.totalDistanceMeters >= 5000,
  ),
  _Badge(
    const BadgeDefinition(
      id: 'multi_day',
      title: '継続の証',
      description: '2日以上、日を変えて散歩した',
      icon: Icons.calendar_month,
    ),
    (stats) => stats.distinctWalkDays >= 2,
  ),
  _Badge(
    const BadgeDefinition(
      id: 'five_walks',
      title: '散歩マスター',
      description: '散歩を5回完了した',
      icon: Icons.emoji_events,
    ),
    (stats) => stats.totalWalks >= 5,
  ),
];

/// 全バッジの定義一覧(バッジ画面の表示に使う)。
List<BadgeDefinition> get allBadgeDefinitions =>
    _badges.map((b) => b.definition).toList();

/// 現在の実績[stats]と、すでに解除済みの[unlockedIds]を比較し、
/// 新たに条件を満たしたバッジの定義を返す。
List<BadgeDefinition> evaluateNewlyUnlocked(
  WalkStats stats,
  Set<String> unlockedIds,
) {
  return _badges
      .where((b) => !unlockedIds.contains(b.definition.id))
      .where((b) => b.isAchieved(stats))
      .map((b) => b.definition)
      .toList();
}
