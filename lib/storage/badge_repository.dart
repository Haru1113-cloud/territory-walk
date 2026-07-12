// このファイルの役割:
// 解除済みバッジのID一覧をローカルに永続化する(shared_preferences)。
// バッジの定義そのもの(タイトル・アイコン等)は保存せず、IDだけ保存する
// (定義はlib/badges/badge_definitions.dartが常に最新の内容を持つため)。

import 'package:shared_preferences/shared_preferences.dart';

class BadgeRepository {
  static const _storageKey = 'unlocked_badge_ids';

  Future<Set<String>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_storageKey);
    return saved?.toSet() ?? {};
  }

  Future<void> save(Set<String> unlockedIds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, unlockedIds.toList());
  }
}
