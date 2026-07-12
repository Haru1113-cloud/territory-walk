// このファイルの役割:
// アプリ全体で使う配色・共通スタイル値を1箇所にまとめる。
// 「白ベース+ビビッドな差し色」のポップなトーンにする狙いは
// territory-rendering skillを参照。

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// 差し色(記録中の軌跡・スタートボタンなど、最も目立たせたい要素)。
  static const accent = Color(0xFFE1261C);

  /// 確定済み領土の塗り(白い地図の上でよく映るビビッドなライム)。
  static const territoryFill = Color(0xFFD4FF3D);

  /// 確定済み領土の輪郭(塗りとのコントラストを出す濃色)。
  static const territoryBorder = Color(0xFF1A1A1A);

  /// 本文テキスト・見出し。
  static const ink = Color(0xFF1A1A1A);

  /// パネルの背景。
  static const panelBackground = Colors.white;
}
