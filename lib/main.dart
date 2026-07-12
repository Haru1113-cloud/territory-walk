// このファイルの役割:
// アプリのエントリーポイント。Providerの登録とMaterialAppの起動のみを行う。

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'screens/walk_screen.dart';
import 'state/tera_walk_controller.dart';
import 'widgets/app_style.dart';

void main() {
  runApp(const TeraWalkApp());
}

class TeraWalkApp extends StatelessWidget {
  const TeraWalkApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TeraWalkController(),
      child: MaterialApp(
        title: 'テラウォーク',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorSchemeSeed: AppColors.trail,
          scaffoldBackgroundColor: AppColors.background,
          focusColor: AppColors.trail,
          textTheme: ThemeData.dark().textTheme.apply(
                bodyColor: AppColors.ink,
                displayColor: AppColors.ink,
              ),
          snackBarTheme: SnackBarThemeData(
            backgroundColor: AppColors.panel,
            contentTextStyle: const TextStyle(color: AppColors.ink),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppColors.radiusSmall),
            ),
          ),
        ),
        home: const WalkScreen(),
      ),
    );
  }
}
