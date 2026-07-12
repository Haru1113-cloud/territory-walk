// このファイルの役割:
// アプリ起動時のスモークテスト。メイン画面が表示されることだけを確認する。

import 'package:flutter_test/flutter_test.dart';

import 'package:tera_walk/main.dart';

void main() {
  testWidgets('起動するとテラウォークの画面が表示される',
      (WidgetTester tester) async {
    await tester.pumpWidget(const TeraWalkApp());

    expect(find.text('テラウォーク'), findsOneWidget);
    expect(find.text('スタート'), findsOneWidget);
  });
}
