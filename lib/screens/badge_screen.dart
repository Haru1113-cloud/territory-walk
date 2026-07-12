// このファイルの役割:
// バッジ(実績)の一覧画面。解除済みは色付き、未解除はグレーアウトで表示する。

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../badges/badge.dart';
import '../badges/badge_definitions.dart';
import '../state/tera_walk_controller.dart';
import '../widgets/app_style.dart';

class BadgeScreen extends StatelessWidget {
  const BadgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final unlockedIds = context.watch<TeraWalkController>().unlockedBadgeIds;

    return Scaffold(
      appBar: AppBar(title: const Text('バッジ')),
      body: ListView.separated(
        itemCount: allBadgeDefinitions.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final badge = allBadgeDefinitions[index];
          final unlocked = unlockedIds.contains(badge.id);
          return _BadgeTile(badge: badge, unlocked: unlocked);
        },
      ),
    );
  }
}

class _BadgeTile extends StatelessWidget {
  const _BadgeTile({required this.badge, required this.unlocked});

  final BadgeDefinition badge;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final color = unlocked ? AppColors.badgeAccent : AppColors.border;

    return ListTile(
      leading: Icon(badge.icon, color: color, size: 32),
      title: Text(
        badge.title,
        style: TextStyle(
          color: unlocked ? AppColors.ink : AppColors.inkMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
      subtitle: Text(
        badge.description,
        style: const TextStyle(color: AppColors.inkMuted),
      ),
      trailing: unlocked
          ? const Icon(Icons.check_circle, color: AppColors.badgeAccent)
          : const Icon(Icons.lock_outline, color: AppColors.border),
    );
  }
}
