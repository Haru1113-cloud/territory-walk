// このファイルの役割:
// 幾何計算・輪の自動クローズ判定で使う閾値を1箇所にまとめる。
// 値の意味・根拠は .claude/skills/geo-math/SKILL.md を参照。

/// これより短い移動はGPSのブレとみなして軌跡に追加しない(メートル)。
const double minMoveMeters = 5;

/// スタート地点からこの距離以内に戻ってきたら輪を閉じる(メートル)。
const double closeRadiusMeters = 15;

/// 輪を閉じる判定を行うために最低限必要な軌跡ポイント数。
const int minPointsToClose = 5;
