// このファイルの役割:
// 獲得済みバッジを、一覧画面に行かなくてもひと目でわかるように
// 小さなチップとして常時表示する部品(操作パネルに組み込んで使う)。

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../badges/badge.dart';
import '../badges/badge_definitions.dart';
import '../state/tera_walk_controller.dart';
import 'app_style.dart';

class BadgeChipRow extends StatelessWidget {
  const BadgeChipRow({super.key});

  @override
  Widget build(BuildContext context) {
    final unlockedIds = context.watch<TeraWalkController>().unlockedBadgeIds;
    final unlockedBadges =
        allBadgeDefinitions.where((b) => unlockedIds.contains(b.id)).toList();

    if (unlockedBadges.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: unlockedBadges.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) => _BadgeChip(badge: unlockedBadges[index]),
      ),
    );
  }
}

class _BadgeChip extends StatelessWidget {
  const _BadgeChip({required this.badge});

  final BadgeDefinition badge;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: badge.description,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.badgeAccent.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.badgeAccent.withValues(alpha: 0.6)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(badge.icon, color: AppColors.badgeAccent, size: 16),
            const SizedBox(width: 6),
            Text(
              badge.title,
              style: const TextStyle(
                color: AppColors.badgeAccent,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
