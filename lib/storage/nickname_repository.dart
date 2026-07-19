// このファイルの役割:
// 表示用ニックネームを端末ローカルに永続化する(shared_preferences)。
// アカウント登録は行わないので、Firebase側には保存せず、確定した領土を
// 公開するときに毎回このニックネームを一緒に送るだけにする。

import 'package:shared_preferences/shared_preferences.dart';

class NicknameRepository {
  static const _storageKey = 'nickname';

  Future<String?> load() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_storageKey);
  }

  /// nullまたは空文字を渡すと未設定の状態に戻す(loadがnullを返すようになる)。
  Future<void> save(String? nickname) async {
    final prefs = await SharedPreferences.getInstance();
    if (nickname == null || nickname.isEmpty) {
      await prefs.remove(_storageKey);
      return;
    }
    await prefs.setString(_storageKey, nickname);
  }
}
