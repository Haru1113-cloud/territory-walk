---
description: テリトリー散歩MVPの実装をDESIGN.mdに沿って再実行する
---

`docs/DESIGN.md` を読み込み、そこに書かれた仕様に沿って `lib/` 以下の
Flutter MVP実装を行う（または既存実装を設計書と一致するよう修正する）。

手順:

1. `docs/DESIGN.md` を読み、現在のスコープ（ソロ版のみ、対戦・サーバー同期は
   実装しない）を確認する。
2. `.claude/skills/geo-math/SKILL.md`、`.claude/skills/flutter-conventions/SKILL.md`、
   `.claude/skills/territory-rendering/SKILL.md` を読み、実装の詳細ルールを確認する。
3. `flutter-implementer` サブエージェントに実装（または差分修正）を依頼する。
4. 実装後、`flutter analyze` と `flutter build`（対象プラットフォームに応じて
   `apk` または `ios --no-codesign` 等）でビルドが通ることを確認する。
5. 変更したファイルの一覧と、実行したコマンド・結果を報告する。

このコマンドは「MVPの機能範囲を満たす実装が失われた／崩れた」ときの
再実行、または軽微な仕様変更後の再実装に使う。大きな仕様変更を
加える場合は、先に `docs/DESIGN.md` を更新してから実行すること。
