// このファイルの役割:
// アプリのエントリーポイント。Providerの登録とMaterialAppの起動のみを行う。

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'firebase_options.dart';
import 'screens/home_shell.dart';
import 'state/tera_walk_controller.dart';
import 'widgets/app_style.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const TeraWalkApp());
}

class TeraWalkApp extends StatelessWidget {
  const TeraWalkApp({super.key, this.controller});

  /// テスト用の差し替え口。通常は指定しない(Controllerが内部で生成する)。
  final TeraWalkController? controller;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => controller ?? TeraWalkController(),
      child: MaterialApp(
        title: 'テラウォーク',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.light,
          colorSchemeSeed: AppColors.trail,
          scaffoldBackgroundColor: AppColors.background,
          focusColor: AppColors.trail,
          textTheme: ThemeData.light().textTheme.apply(
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
        home: const HomeShell(),
      ),
    );
  }
}
