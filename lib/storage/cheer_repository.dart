// このファイルの役割:
// 応援スタンプ(Cheer)をFirestoreへ送信・購読するリポジトリ。
// ドキュメントID を「送信先_送信元」の組み合わせで固定することで、
// 同じ相手に何度押しても1件のまま(連打で数を水増しできない)にしている。

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/cheer.dart';

class CheerRepository {
  CheerRepository({FirebaseFirestore? firestore})
      : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('territory_cheers');

  Future<void> send({required String fromOwnerId, required String toOwnerId}) async {
    final docId = '${toOwnerId}_$fromOwnerId';
    await _collection.doc(docId).set(
          Cheer(fromOwnerId: fromOwnerId, toOwnerId: toOwnerId).toJson(),
        );
  }

  Stream<List<Cheer>> watchAll() {
    return _collection.snapshots().map(
          (snapshot) =>
              snapshot.docs.map((doc) => Cheer.fromJson(doc.data())).toList(),
        );
  }
}
