// このファイルの役割:
// アプリのエントリーポイント。Providerの登録とMaterialAppの起動のみを行う。

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/walk_screen.dart';
import 'state/territory_walk_controller.dart';
import 'widgets/app_style.dart';

void main() {
  runApp(const TerritoryWalkApp());
}

class TerritoryWalkApp extends StatelessWidget {
  const TerritoryWalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TerritoryWalkController(),
      child: MaterialApp(
        title: 'テリトリー散歩',
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: AppColors.primary,
          scaffoldBackgroundColor: Colors.white,
          focusColor: AppColors.focus,
          textTheme: ThemeData.light().textTheme.apply(
                bodyColor: AppColors.ink,
                displayColor: AppColors.ink,
              ),
        ),
        home: const WalkScreen(),
      ),
    );
  }
}
