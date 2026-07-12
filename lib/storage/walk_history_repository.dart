// このファイルの役割:
// 散歩記録(WalkRecord)のリストをローカルに永続化する(shared_preferences、
// JSON文字列)。territory_repository.dartと同じ方針・実装パターン。

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/walk_record.dart';

class WalkHistoryRepository {
  static const _storageKey = 'walk_history';

  Future<List<WalkRecord>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return [];

    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => WalkRecord.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<WalkRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(records.map((r) => r.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
