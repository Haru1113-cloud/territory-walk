// このファイルの役割:
// 週替わりのチーム目標(みんなの合計獲得面積)を計算する純粋関数。
// バッジと違い、Firestoreに追加のスキーマは持たない。既存のterritories/
// othersTerritoriesが持つclosedAtから「今週分」を絞り込むだけで実現できる
// (badge_definitions.dartと同様、UIに依存しないロジックはここに集約する)。

import '../models/territory.dart';

/// 週替わりでローテーションするチーム目標(獲得面積、m²)。
const _weekTargetsSquareMeters = [500.0, 800.0, 1200.0, 600.0, 1500.0, 2000.0];

/// 固定の基準日(月曜)。ここからの経過日数を7で割った商を「週番号」とする。
/// 実際のISO週番号と厳密には一致しないが、全ユーザーが同じ計算式で同じ
/// 週境界・同じ目標値を共有できれば十分なので、ここでは簡略化している。
final _epoch = DateTime.utc(2024, 1, 1);

int _weekIndex(DateTime now) => now.toUtc().difference(_epoch).inDays ~/ 7;

/// [now]が属する週の開始日時(UTC、月曜起点)。
DateTime currentWeekStart(DateTime now) {
  return _epoch.add(Duration(days: _weekIndex(now) * 7));
}

/// 今週のチーム目標(合計獲得面積、m²)。
double currentWeekTargetAreaSquareMeters(DateTime now) {
  return _weekTargetsSquareMeters[_weekIndex(now) % _weekTargetsSquareMeters.length];
}

/// [territories]のうち、[now]が属する週に確定した(closedAtがその週以降の)
/// ものだけを残す。
List<Territory> territoriesThisWeek(List<Territory> territories, DateTime now) {
  final start = currentWeekStart(now);
  return territories.where((t) => !t.closedAt.isBefore(start)).toList();
}
