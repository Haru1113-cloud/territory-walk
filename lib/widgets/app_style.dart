// このファイルの役割:
// アプリ全体で使う配色・共通スタイル値を1箇所にまとめる。
// 「暗い舞台の上でネオンが光る」ゲームらしいトーンにするための
// デザイントークン。採用理由・使い分けはterritory-rendering skillを参照。
// (2026-07: デジタル庁デザインシステム準拠のライトテーマから、
//  ダーク×グロー配色へ全面的に差し替えた)

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// アプリ全体の背景。ほぼ黒に近い暗いネイビー。
  static const background = Color(0xFF0B0D14);

  /// パネル・カードの面。暗い半透明のガラス調(背後にBackdropFilterで
  /// ぼかしを重ねる前提の色)。
  static const panel = Color(0xEB121520);

  /// 本文テキスト・見出し。明るいオフホワイト。
  static const ink = Color(0xFFF3F1FA);

  /// 補助テキスト。くすんだグレー。
  static const inkMuted = Color(0xFF8B90A6);

  /// 領土(獲得エリア)の色。紫系。塗り・輪郭・グロー・獲得トーストの
  /// 背景など、「領土を確定する」という行為に関わる箇所で一貫して使う。
  static const territory = Color(0xFF8B6CFF);

  /// 軌跡(移動ルート)の色。ミント系。「今動いている・進んでいる」ことを
  /// 表す箇所(軌跡の線、今回の距離のハイライト、スタートボタン等)で使う。
  static const trail = Color(0xFF2FE6B8);

  /// 達成・バッジの色。琥珀系。
  static const badgeAccent = Color(0xFFFFC24B);

  /// 他ユーザーが確定した領土の色。自分の領土(紫)とひと目で区別できる
  /// よう、離れた色相(珊瑚色)にする。
  static const othersTerritory = Color(0xFFFF6B81);

  /// 地図タイルにかけるデュオトーンの色。生のOSM系タイルをそのまま見せず、
  /// 単色トーンで塗って「舞台の書き割り」のようにフラット化する狙い
  /// (BlendMode.colorでタイルの明度だけ残し、色相をこの色に置き換える)。
  static const mapTint = Color(0xFF2B3454);

  /// 明るいアクセント色(territory/trail/badgeAccent)の上に乗せる文字色。
  /// 背景が明るいため、白文字ではなくほぼ黒に近い色でコントラストを取る。
  static const onAccent = Color(0xFF06110D);

  /// 枠線・区切り線(暗い背景の上で使う、控えめな明度)。
  static const border = Color(0xFF2A2E3D);

  /// ボタン・カードの角丸。
  static const radiusSmall = 8.0;

  /// ボトムシートなど大きめのコンテナの角丸。
  static const radiusLarge = 24.0;
}
