// このファイルの役割:
// 確定済み領土のリストをローカルに永続化する(shared_preferences、JSON文字列)。
// 合計面積はTerritoryのリストから都度算出する一本の真実とし、別途保存しない
// (理由はDESIGN.md 3章を参照)。

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/territory.dart';

class TerritoryRepository {
  static const _storageKey = 'territories';

  Future<List<Territory>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw == null) return [];

    final decoded = jsonDecode(raw) as List;
    return decoded
        .map((e) => Territory.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> save(List<Territory> territories) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(territories.map((t) => t.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
