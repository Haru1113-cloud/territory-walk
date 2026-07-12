// このファイルの役割:
// アプリ全体で使う配色・共通スタイル値を1箇所にまとめる。
// 色・角丸の値は「デジタル庁デザインシステム」の公式トークンパッケージ
// (@digital-go-jp/tailwind-theme-plugin v1.0.1)から採ったもの。
// 採用理由・トークン名の対応はterritory-rendering skillを参照。

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// プライマリ(スタートボタンなど主要な操作)。DADSトークン: key/blue-900。
  static const primary = Color(0xFF0017C1);

  /// フォーカスリングなど、プライマリより明るい強調色。DADSトークン: focus-blue。
  static const focus = Color(0xFF0877D7);

  /// 確定済み領土の塗り。「成功」を表す色を流用する。DADSトークン: success-1。
  static const territoryFill = Color(0xFF259D63);

  /// 確定済み領土の輪郭(塗りより濃い成功色)。DADSトークン: success-2。
  static const territoryBorder = Color(0xFF197A4B);

  /// 本文テキスト・見出し。DADSトークン: solid-gray-900。
  static const ink = Color(0xFF1A1A1A);

  /// 補助テキスト(白背景でコントラスト比4.5:1を確保)。DADSトークン: solid-gray-536。
  static const inkMuted = Color(0xFF767676);

  /// 枠線・区切り線。DADSトークン: solid-gray-300。
  static const border = Color(0xFFB3B3B3);

  /// パネルの背景。
  static const panelBackground = Colors.white;

  /// ボタン・カードの角丸。DADSトークン: radius-8。
  static const radiusSmall = 8.0;

  /// ボトムシートなど大きめのコンテナの角丸。DADSトークン: radius-24。
  static const radiusLarge = 24.0;
}
