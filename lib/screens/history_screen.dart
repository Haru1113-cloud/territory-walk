// このファイルの役割:
// 振り返り画面の1段階目。過去の散歩記録を新しい順の一覧で表示し、
// タップすると詳細地図画面(history_detail_screen.dart)に遷移する。

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/walk_record.dart';
import '../state/tera_walk_controller.dart';
import '../widgets/app_style.dart';
import '../widgets/format.dart';
import 'history_detail_screen.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final walkHistory = context.watch<TeraWalkController>().walkHistory;
    final records = walkHistory.reversed.toList();

    return Scaffold(
      appBar: AppBar(title: const Text('散歩の記録')),
      body: records.isEmpty
          ? const Center(
              child: Text(
                'まだ記録がありません。\n散歩をスタート→ストップすると記録されます。',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.inkMuted),
              ),
            )
          : ListView.separated(
              itemCount: records.length,
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) =>
                  _WalkRecordTile(record: records[index]),
            ),
    );
  }
}

class _WalkRecordTile extends StatelessWidget {
  const _WalkRecordTile({required this.record});

  final WalkRecord record;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.directions_walk, color: AppColors.trail),
      title: Text(formatDate(record.startedAt)),
      subtitle: Text(
        '距離 ${formatDistance(record.distanceMeters)}'
        '${record.areaSquareMeters > 0 ? ' ・ 面積 ${formatArea(record.areaSquareMeters)}' : ''}',
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => HistoryDetailScreen(record: record),
          ),
        );
      },
    );
  }
}
