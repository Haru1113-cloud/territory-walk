// このファイルの役割:
// アプリ起動時のスモークテスト。メイン画面が表示されることだけを確認する。
// Firebase未初期化のテスト環境でも動くよう、認証・Firestore同期は
// 実際のFirebaseに触れないフェイクに差し替える。

import 'package:flutter_test/flutter_test.dart';

import 'package:tera_walk/auth/auth_service.dart';
import 'package:tera_walk/main.dart';
import 'package:tera_walk/models/cheer.dart';
import 'package:tera_walk/models/territory.dart';
import 'package:tera_walk/state/tera_walk_controller.dart';
import 'package:tera_walk/storage/cheer_repository.dart';
import 'package:tera_walk/storage/remote_territory_repository.dart';

class _FakeAuthService extends AuthService {
  @override
  Future<String> ensureSignedIn() async => 'test-user';
}

class _FakeRemoteTerritoryRepository extends RemoteTerritoryRepository {
  @override
  Future<void> publish(Territory territory, String ownerId, String? ownerName) async {}

  @override
  Stream<List<Territory>> watchAll() => const Stream.empty();
}

class _FakeCheerRepository extends CheerRepository {
  @override
  Future<void> send({required String fromOwnerId, required String toOwnerId}) async {}

  @override
  Stream<List<Cheer>> watchAll() => const Stream.empty();
}

void main() {
  testWidgets('起動するとテラウォークの画面が表示される',
      (WidgetTester tester) async {
    final controller = TeraWalkController(
      authService: _FakeAuthService(),
      remoteRepository: _FakeRemoteTerritoryRepository(),
      cheerRepository: _FakeCheerRepository(),
    );

    await tester.pumpWidget(TeraWalkApp(controller: controller));

    expect(find.text('テラウォーク'), findsOneWidget);
    expect(find.text('スタート'), findsOneWidget);
  });
}
