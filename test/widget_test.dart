// このファイルの役割:
// アプリ起動時のスモークテスト。メイン画面が表示されることだけを確認する。

import 'package:flutter_test/flutter_test.dart';

import 'package:territory_walk/main.dart';

void main() {
  testWidgets('起動するとテリトリー散歩の画面が表示される',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TerritoryWalkApp());

    expect(find.text('テリトリー散歩'), findsOneWidget);
    expect(find.text('スタート'), findsOneWidget);
  });
}
