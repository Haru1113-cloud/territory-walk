// このファイルの役割:
// 獲得面積の合計で並べた、自分と他ユーザーのランキング画面。
// 対戦(奪い合い)要素はなく、あくまで眺めて楽しむ一覧。

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/ranking_entry.dart';
import '../state/tera_walk_controller.dart';
import '../widgets/app_style.dart';
import '../widgets/format.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ranking = context.watch<TeraWalkController>().ranking;

    return Scaffold(
      appBar: AppBar(title: const Text('ランキング')),
      body: ranking.isEmpty
          ? const Center(
              child: Text(
                'まだ誰も領土を獲得していません',
                style: TextStyle(color: AppColors.inkMuted),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: ranking.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                return _RankingTile(rank: index + 1, entry: ranking[index]);
              },
            ),
    );
  }
}

class _RankingTile extends StatelessWidget {
  const _RankingTile({required this.rank, required this.entry});

  final int rank;
  final RankingEntry entry;

  @override
  Widget build(BuildContext context) {
    final name = entry.ownerName ?? (entry.isMe ? 'あなた' : '名無しさん');

    return ListTile(
      tileColor: entry.isMe ? AppColors.trail.withValues(alpha: 0.08) : null,
      leading: SizedBox(
        width: 32,
        child: Text(
          '$rank',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: rank <= 3 ? AppColors.badgeAccent : AppColors.inkMuted,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
      title: Text(
        entry.isMe ? '$name(自分)' : name,
        style: const TextStyle(color: AppColors.ink, fontWeight: FontWeight.w700),
      ),
      subtitle: Text(
        '領土 ${entry.territoryCount}件',
        style: const TextStyle(color: AppColors.inkMuted, fontSize: 12),
      ),
      trailing: Text(
        formatArea(entry.totalAreaSquareMeters),
        style: const TextStyle(color: AppColors.territory, fontWeight: FontWeight.w800),
      ),
    );
  }
}
