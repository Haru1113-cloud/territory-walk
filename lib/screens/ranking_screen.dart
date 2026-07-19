// このファイルの役割:
// 獲得面積の合計で並べた、自分と他ユーザーのランキング画面。
// 対戦(奪い合い)要素はなく、あくまで眺めて楽しむ一覧。他ユーザーには
// 応援スタンプを送れる。

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/tera_walk_controller.dart';
import '../widgets/app_style.dart';
import '../widgets/person_area_tile.dart';

class RankingScreen extends StatelessWidget {
  const RankingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TeraWalkController>();
    final ranking = controller.ranking;
    final cheerCounts = controller.cheerCounts;

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
              // 下部の浮遊ナビゲーションバーに最後の項目が隠れないよう、
              // 通常の余白に加えてバーの高さ分を確保する。
              padding: const EdgeInsets.fromLTRB(
                0,
                8,
                0,
                8 + AppColors.bottomNavBarHeight,
              ),
              itemCount: ranking.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final entry = ranking[index];
                return PersonAreaTile(
                  rank: index + 1,
                  entry: entry,
                  cheerCount: cheerCounts[entry.ownerId] ?? 0,
                  onCheer: entry.isMe
                      ? null
                      : () => controller.sendCheer(entry.ownerId),
                );
              },
            ),
    );
  }
}
