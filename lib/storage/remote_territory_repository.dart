// このファイルの役割:
// 確定済み領土をFirestoreへ公開し、他ユーザーの領土を読み取るための
// リポジトリ。ローカル保存(territory_repository.dart)とは別物で、
// 「自分の領土を他人に見せる/他人の領土を見る」ためだけに使う。

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/territory.dart';

class RemoteTerritoryRepository {
  RemoteTerritoryRepository({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  // AuthServiceと同様、Firebase未初期化のテスト環境でもサブクラス化だけで
  // 安全にフェイクできるよう、遅延評価にしておく。
  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('territories');

  /// 確定した領土をFirestoreへ公開する。
  Future<void> publish(Territory territory, String ownerId, String? ownerName) async {
    final data = territory.toJson()
      ..['ownerId'] = ownerId
      ..['ownerName'] = ownerName;
    await _collection.add(data);
  }

  /// 全ユーザーの領土をリアルタイムに購読する(自分の分も含む。
  /// 自分の領土との重複除外は呼び出し側で行う)。
  Stream<List<Territory>> watchAll() {
    return _collection.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => Territory.fromJson(doc.data()))
              .toList(),
        );
  }
}
