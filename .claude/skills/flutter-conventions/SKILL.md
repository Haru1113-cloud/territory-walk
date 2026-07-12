---
name: flutter-conventions
description: このプロジェクトのFlutterコーディング規約（状態管理の方針・フォルダ分割ルール・命名規則）
---

# いつ読むか

`lib/` 以下に新しいファイルを追加する、既存のウィジェット/状態管理コードを
リファクタする、または「このロジックはどこに置くべきか」迷ったときに読む。
幾何計算の数式そのものを調べたいときは代わりに `geo-math` skillを読む。

---

## 状態管理の方針

- `provider` パッケージを使う。`Riverpod` や `Bloc` のような重い仕組みは
  このアプリの規模（ソロ版・1画面）には過剰なので使わない。
- アプリ全体の状態は単一の `ChangeNotifier`（`TerritoryWalkController` を想定）に
  集約する。「軌跡用の状態」「領土用の状態」「モード用の状態」のように
  Providerを分割しない。状態同士の整合性（軌跡が閉じたら領土に移す、等）を
  1箇所で管理した方がシンプルになるため。
- ウィジェット側は `Consumer` または `context.watch` で必要な値だけを読む。
  ビジネスロジック（距離計算・面積計算・輪のクローズ判定）はウィジェットにも
  Controllerにも直接書かず、`lib/geo/` の純粋関数として実装し、Controllerから
  呼び出す（テストしやすくするため）。

## フォルダ構成

```
lib/
├── main.dart                    アプリのエントリーポイント。Provider登録とMaterialAppのみ
├── models/                      データモデル（振る舞いを持たない型定義）
│   ├── track_point.dart         軌跡上の1点（緯度経度＋取得時刻）
│   └── territory.dart           確定済みの領土（点の配列＋面積）
├── geo/                         幾何計算・GPS処理（UIに依存しない純粋なロジック）
│   ├── territory_constants.dart 閾値の定数（minMoveMeters等）
│   ├── distance.dart            ハバーサイン距離計算
│   ├── polygon_area.dart        座標変換＋靴ひも公式の面積計算
│   └── loop_detector.dart       ブレ除去フィルタ＋輪の自動クローズ判定
├── state/                       アプリの状態管理
│   └── territory_walk_controller.dart  ChangeNotifier本体
├── location/                    位置情報の取得（GPSモード用）
│   └── location_service.dart    geolocatorパッケージのラッパー
├── storage/                     ローカル永続化（合計面積・領土リストの保存）
│   └── territory_repository.dart
├── screens/                     画面
│   └── walk_screen.dart         メイン画面（地図＋操作パネル）
└── widgets/                     screens内で使う部品
    ├── app_style.dart            配色などの共通スタイル値（AppColors）
    ├── mode_toggle.dart          テスト/GPSモード切替
    ├── control_panel.dart        スタート/ストップ・輪を閉じるボタン
    └── territory_map.dart        flutter_map本体（軌跡・領土ポリゴンの描画）
```

責務の分離ルール:
- `geo/` はFlutterのimportを持たない（`dart:math` のみに依存する純粋Dart）。
  ウィジェットテストなしでロジックの単体テストができる状態を保つため。
- `models/` は基本的にコンストラクタとフィールドのみ。計算ロジックを
  メソッドとして生やさない（計算は `geo/` に置く）。
- 地図の見た目・配色に関する詳細は `territory-rendering` skillを参照。

## 命名規則

- ファイル名: `snake_case.dart`
- クラス名: `UpperCamelCase`
- 変数・関数名: `lowerCamelCase`
- 定数: `lowerCamelCase`（Dartの慣習に従い `UPPER_SNAKE_CASE` は使わない）
- 「輪」「領土」「軌跡」など日本語の概念に対応する英語名は以下に統一する。
  プロトタイプの変数名とも対応させてあるので、実装時に迷ったらこの表を見る。

| 日本語 | 英語（コード上の名前） |
|---|---|
| 軌跡（記録中、未確定） | `trail` / `TrackPoint` |
| 領土（確定済み） | `territory` / `Territory` |
| 輪が閉じる | `closeLoop` |
| 合計獲得面積 | `totalAreaSquareMeters` |
| GPSモード / テストモード | `TrackingMode.gps` / `TrackingMode.test` |

## コメント方針

各ファイルの冒頭に、そのファイルの役割を1〜3行の日本語コメントで書く。
プロジェクト全体のコーディング方針（過剰実装より単純さを優先、実装の詳細を
コメントで説明しない、WHYが非自明な場合のみコメントする）は `CLAUDE.md` を参照。
