// このファイルの役割:
// アプリ全体で使う配色・共通スタイル値を1箇所にまとめる。
// 「柔らかい自然光の下で歩く」明るく落ち着いたトーンにするための
// デザイントークン。採用理由・使い分けはterritory-rendering skillを参照。
// (2026-07: ダーク×グロー配色から、クリーム系の明るいトーンへ
//  全面的に差し替えた)

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  /// アプリ全体の背景。生成りに近い、温かみのあるオフホワイト。
  static const background = Color(0xFFF6F3EC);

  /// パネル・カードの面。ほぼ不透明な白のガラス調(背後にBackdropFilterで
  /// ぼかしを重ねる前提の色)。
  static const panel = Color(0xF5FFFFFF);

  /// 本文テキスト・見出し。温かみのある濃いチャコール。
  static const ink = Color(0xFF201C16);

  /// 補助テキスト。中間トーンのグレー。
  static const inkMuted = Color(0xFF7A7568);

  /// 領土(獲得エリア)の色。深い紫。塗り・輪郭・グロー・獲得トーストの
  /// 背景など、「領土を確定する」という行為に関わる箇所で一貫して使う。
  static const territory = Color(0xFF6C4FE0);

  /// 軌跡(移動ルート)の色。深い緑(木々・芝を思わせるトーン)。
  /// 「今動いている・進んでいる」ことを表す箇所(軌跡の線、今回の距離の
  /// ハイライト、スタートボタン等)で使う。
  static const trail = Color(0xFF1C8F63);

  /// 達成・バッジの色。琥珀系。
  static const badgeAccent = Color(0xFFE0A233);

  /// 他ユーザーが確定した領土の色。自分の領土(紫)とひと目で区別できる
  /// よう、離れた色相(珊瑚色)にする。
  static const othersTerritory = Color(0xFFE85D75);

  /// 地図タイルにかけるデュオトーンの色。生のOSM系タイルをそのまま見せず、
  /// 単色トーンで塗って「舞台の書き割り」のようにフラット化する狙い
  /// (BlendMode.colorでタイルの明度だけ残し、色相をこの色に置き換える)。
  /// 明るいテーマに合わせ、淡いセージ(枯れた芝のような色)にしている。
  static const mapTint = Color(0xFFDAD8C4);

  /// 濃いアクセント色(territory/trail/badgeAccent/othersTerritory)の上に
  /// 乗せる文字色。アクセント自体が中〜濃いトーンなので、白文字でコントラストを取る。
  static const onAccent = Color(0xFFFFFFFF);

  /// 枠線・区切り線(明るい背景の上で使う、控えめな明度)。
  static const border = Color(0xFFE3E0D3);

  /// ボタン・カードの角丸。
  static const radiusSmall = 8.0;

  /// ボトムシートなど大きめのコンテナの角丸。
  static const radiusLarge = 24.0;

  /// 浮遊型の下部ナビゲーションバー(`HomeShell`)が占める高さの目安
  /// (NavigationBar本体64px＋インジケーターの余白のための上下padding16px
  /// ＋その下の余白12px)。`HomeShell`はScaffoldの`extendBody: true`で
  /// タブの中身をバーの裏側まで敷き詰めているため、タブ側で独自に画面下部へ
  /// 固定表示するUI(`WalkScreen`の操作パネル等)は、デバイスのセーフエリアに
  /// 加えてこの高さ分も余白として確保しないとバーの下に隠れてしまう。
  static const bottomNavBarHeight = 92.0;
}
