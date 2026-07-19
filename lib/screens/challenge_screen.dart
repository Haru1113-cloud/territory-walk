// このファイルの役割:
// 週替わりのチーム目標(みんなの合計獲得面積)と、今週分だけの
// 貢献ランキングを表示する画面。対戦要素はなく、協力して目標を
// 目指す「今週どれだけ広げられたか」を眺めるための画面。

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/tera_walk_controller.dart';
import '../widgets/app_style.dart';
import '../widgets/format.dart';
import '../widgets/person_area_tile.dart';

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TeraWalkController>();
    final team = controller.weeklyTeamAreaSquareMeters;
    final target = controller.weeklyChallengeTargetAreaSquareMeters;
    final progress = (team / target).clamp(0.0, 1.0);
    final ranking = controller.weeklyChallengeRanking;
    final cheerCounts = controller.cheerCounts;

    return Scaffold(
      appBar: AppBar(title: const Text('今週のチャレンジ')),
      body: ListView(
        // 下部の浮遊ナビゲーションバーに最後の項目が隠れないよう、
        // 通常の余白に加えてバーの高さ分を確保する。
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          16 + AppColors.bottomNavBarHeight,
        ),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.panel,
              borderRadius: BorderRadius.circular(AppColors.radiusLarge),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'みんなで合計 ${formatArea(target)} を目指そう',
                  style: const TextStyle(
                    color: AppColors.ink,
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 10,
                    backgroundColor: AppColors.border,
                    color: AppColors.trail,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '現在 ${formatArea(team)} / ${formatArea(target)}',
                  style: const TextStyle(color: AppColors.inkMuted, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            '今週の貢献',
            style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          if (ranking.every((e) => e.totalAreaSquareMeters == 0))
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Text(
                'まだ今週の獲得はありません。散歩に出かけよう。',
                style: TextStyle(color: AppColors.inkMuted),
              ),
            )
          else
            ...List.generate(ranking.length, (index) {
              final entry = ranking[index];
              if (entry.totalAreaSquareMeters <= 0) return const SizedBox.shrink();
              return PersonAreaTile(
                rank: index + 1,
                entry: entry,
                cheerCount: cheerCounts[entry.ownerId] ?? 0,
                onCheer:
                    entry.isMe ? null : () => controller.sendCheer(entry.ownerId),
              );
            }),
        ],
      ),
    );
  }
}
