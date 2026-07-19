// このファイルの役割:
// 他ユーザーの領土と自分の領土を区別するためだけの、最小限の匿名認証
// ラッパー。ログイン画面・ユーザー名などは持たない(誰が誰かを表示する
// 機能はスコープ外)。FirebaseAuthのuidを「領土の持ち主ID」として使う。

import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  // FirebaseAuth.instanceへのアクセスをgetter経由の遅延評価にしておく。
  // フィールド初期化子で即座に評価すると、Firebase未初期化のテスト環境で
  // サブクラス化してもコンストラクタの時点で例外になってしまうため。
  FirebaseAuth get _auth => FirebaseAuth.instance;

  /// 端末固有のユーザーIDを返す。未サインインなら匿名サインインしてから返す。
  Future<String> ensureSignedIn() async {
    final current = _auth.currentUser;
    if (current != null) return current.uid;

    final credential = await _auth.signInAnonymously();
    return credential.user!.uid;
  }
}
