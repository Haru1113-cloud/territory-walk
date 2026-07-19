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
- アプリ全体の状態は単一の `ChangeNotifier`（`TeraWalkController`）に
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
├── main.dart                    アプリのエントリーポイント。Firebase初期化・
│                                  Provider登録・MaterialAppのみ
├── firebase_options.dart        flutterfire configureが生成するFirebase設定
│                                  (機密情報ではない、コミットして問題ない)
├── models/                      データモデル（振る舞いを持たない型定義）
│   ├── track_point.dart         軌跡上の1点（緯度経度＋取得時刻）
│   ├── territory.dart           確定済みの領土（点の配列＋面積＋持ち主情報）
│   ├── walk_record.dart         1回の散歩の記録（日時・距離・面積・ルート）
│   └── ranking_entry.dart       ランキング画面用の1ユーザー分の集計結果
├── geo/                         幾何計算・GPS処理（UIに依存しない純粋なロジック）
│   ├── territory_constants.dart 閾値の定数（minMoveMeters等）
│   ├── distance.dart            ハバーサイン距離計算
│   ├── polygon_area.dart        座標変換＋靴ひも公式の面積計算
│   └── loop_detector.dart       ブレ除去フィルタ＋輪の自動クローズ判定
├── state/                       アプリの状態管理
│   └── tera_walk_controller.dart  ChangeNotifier本体
├── location/                    位置情報の取得
│   └── location_service.dart    geolocatorパッケージのラッパー
├── auth/                        他ユーザーと自分の領土を区別するためだけの
│                                  最小限の認証（ログイン画面は持たない）
│   └── auth_service.dart        FirebaseAuthの匿名サインインラッパー
├── storage/                     永続化
│   ├── territory_repository.dart        領土リストのローカル保存(shared_preferences)
│   ├── walk_history_repository.dart     散歩記録のローカル保存
│   ├── badge_repository.dart            解除済みバッジIDのローカル保存
│   ├── nickname_repository.dart         ニックネームのローカル保存
│   └── remote_territory_repository.dart 確定済み領土をFirestoreへ公開/購読
│                                          (無料のSparkプランのみで運用)
├── badges/                      バッジ(実績)の定義・達成判定（UIに依存しない）
│   ├── badge.dart                バッジ1件のデータモデル
│   └── badge_definitions.dart    バッジ一覧・達成条件・判定ロジック
├── screens/                     画面
│   ├── home_shell.dart           下部ナビゲーションバーで4画面を切り替える入れ物
│   ├── walk_screen.dart          地図＋操作パネル（「地図」タブ）
│   ├── ranking_screen.dart       獲得面積ランキング（「ランキング」タブ）
│   ├── history_screen.dart       散歩記録の一覧（「記録」タブ・振り返り段階1）
│   ├── history_detail_screen.dart 1件の散歩のルートを地図で見る（段階2、push遷移）
│   └── badge_screen.dart         バッジ一覧（「バッジ」タブ）
└── widgets/                     screens内で使う部品
    ├── app_style.dart            配色などの共通スタイル値（AppColors）
    ├── format.dart                距離・面積の表示用フォーマット関数
    ├── control_panel.dart        スタート/ストップ・輪を閉じるボタン
    ├── territory_map.dart        flutter_map本体（軌跡・領土ポリゴンの描画）
    ├── map_zoom_controls.dart    地図に浮かせるズームコントロール
    ├── map_camera_animation.dart 地図をアニメーション付きで移動させるヘルパー
    ├── glow_line_style.dart      軌跡・領土のグロー(光彩)表現
    ├── territory_gain_toast.dart 領土獲得時の演出トースト
    └── badge_chip_row.dart       獲得済みバッジのチップ行
```

下部ナビゲーションバー（`home_shell.dart`）導入後は、`badge_screen.dart`/
`history_screen.dart`/`ranking_screen.dart`はタブとして直接埋め込まれる
（`Navigator.push`では遷移しない）。`history_detail_screen.dart`のような
「タブの中からさらに1段掘り下げる」画面だけ、従来どおり`Navigator.push`で
遷移する。

責務の分離ルール:
- `geo/` はFlutterのimportを持たない（`dart:math` のみに依存する純粋Dart）。
  ウィジェットテストなしでロジックの単体テストができる状態を保つため。
- `models/` は基本的にコンストラクタとフィールドのみ。計算ロジックを
  メソッドとして生やさない（計算は `geo/` に置く）。
- 地図の見た目・配色に関する詳細は `territory-rendering` skillを参照。

## Controllerの状態（`TeraWalkController`）

現在1画面構成だが、状態の種類が増えてきたため役割ごとに整理する。

- `mode` / `isTracking`: 現在のモードと記録中かどうか。
- `trail`: **今まさに歩いている、まだ閉じていない輪**の軌跡。輪が閉じる
  たびに空にリセットされる（面積計算・輪のクローズ判定専用）。
- `sessionRoute`: **今回のスタート〜ストップの間に記録した全ポイント**。
  輪が閉じてもリセットされない。「今回の散歩の距離」の計算元であり、
  ストップ時に`WalkRecord.route`としてそのまま保存される。GPSのブレ除去
  フィルタもこちらを基準にする（`trail`基準だと輪が閉じた直後にフィルタが
  一瞬効かなくなるため）。
- `territories` / `totalAreaSquareMeters`: 確定済み領土の**全期間の**累計
  （`TerritoryRepository`で永続化、既存の仕組み）。
- `walkHistory`: 過去の散歩記録（`WalkRecord`の配列、`WalkHistoryRepository`で
  永続化）。振り返り画面・バッジ判定の両方から参照する。
- ストップ時、`sessionRoute`が2点以上あれば`WalkRecord`を1件作って
  `walkHistory`に追加・保存する（0〜1点しかない=実質何も歩いていない
  ケースは記録しない）。

「今回のセッションの値」と「全期間の累計・履歴」を明確に分けているのが
このControllerの設計の肝。両者を混ぜると、輪を複数回閉じる1回の散歩や、
アプリを再起動した後の集計が壊れやすくなる。

## バッジ(実績)の仕組み

- `lib/badges/badge_definitions.dart` に「バッジの定義」と「達成条件」を
  集約する。条件判定は`WalkStats`（散歩回数・領土数・累計距離・活動日数）
  という集計値だけを見る純粋関数にしてあり、Controllerや保存形式の詳細を
  知らない。
- `TeraWalkController`は`stop()`のたびに`_evaluateBadges()`を呼び、
  最新の`WalkStats`を集計 → まだ解除していないバッジの中から新たに条件を
  満たしたものを`newlyUnlockedBadges`に積む → `BadgeRepository`にID一覧を
  保存する、という流れ。
- 解除済みかどうかは`unlockedBadgeIds`(IDの集合)だけを保存し、バッジの
  タイトル・アイコン等の見た目は保存しない。バッジの文言やアイコンを
  後から変えても、解除状態はそのまま引き継がれる。
- 「新規解除の通知」は`newlyUnlockedBadges`を1回限りのイベントリストとして
  扱う。`WalkScreen`が`Controller.addListener`でこれを監視し、SnackBarで
  表示したら`clearNewlyUnlockedBadges()`で空にする。Streamや通知パッケージは
  使わず、ChangeNotifierの標準的な仕組みだけで完結させている。
- 新しいバッジを追加したいときは、`badge_definitions.dart`の`_badges`リストに
  `_Badge(定義, 条件判定関数)`を1件足すだけでよい。Controller側の変更は不要。

## 「1回限りの通知」の仕組み（バッジ・領土獲得の演出）

`newlyUnlockedBadges`と同じパターンで、`newlyClosedTerritoryAreas`
（輪が閉じるたびに追加される獲得面積のリスト）も用意してある。どちらも:

1. Controllerが該当イベント発生時にリストへ値を追加する
2. UI（`WalkScreen`）が`Controller.addListener`でリストの変化を検知する
3. UIが演出（SnackBar／独自トースト）を表示し終わったら
   `clearNewlyUnlockedBadges()`/`clearNewlyClosedTerritoryAreas()`を呼んで
   リストを空にする

この「Controllerに1回限りの通知リストを持たせ、UIが表示後にクリアする」
形は今後も演出を増やす際の標準パターンとして使ってよい（Streamや通知
パッケージを新たに導入する必要はない）。

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

## コメント方針

各ファイルの冒頭に、そのファイルの役割を1〜3行の日本語コメントで書く。
プロジェクト全体のコーディング方針（過剰実装より単純さを優先、実装の詳細を
コメントで説明しない、WHYが非自明な場合のみコメントする）は `CLAUDE.md` を参照。
