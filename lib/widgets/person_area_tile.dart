// このファイルの役割:
// 「順位・名前・領土件数・獲得面積」を1行で表示する共通タイル。
// ランキング画面・チャレンジ画面の両方で使う(見た目を揃えるため)。
// 応援スタンプの件数表示・送信ボタンはオプション(onCheerを渡した場合のみ表示)。

import 'package:flutter/material.dart';

import '../models/ranking_entry.dart';
import 'app_style.dart';
import 'format.dart';

class PersonAreaTile extends StatelessWidget {
  const PersonAreaTile({
    super.key,
    required this.rank,
    required this.entry,
    this.cheerCount = 0,
    this.onCheer,
  });

  final int rank;
  final RankingEntry entry;
  final int cheerCount;

  /// nullなら応援ボタンを表示しない(自分自身の行など)。
  final VoidCallback? onCheer;

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
        '領土 ${entry.territoryCount}件'
        '${cheerCount > 0 ? ' ・ 応援 $cheerCount' : ''}',
        style: const TextStyle(color: AppColors.inkMuted, fontSize: 12),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            formatArea(entry.totalAreaSquareMeters),
            style: const TextStyle(
              color: AppColors.territory,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (onCheer != null) ...[
            const SizedBox(width: 4),
            IconButton(
              icon: const Icon(Icons.favorite_border, size: 20),
              color: AppColors.othersTerritory,
              tooltip: '応援する',
              onPressed: onCheer,
            ),
          ],
        ],
      ),
    );
  }
}
