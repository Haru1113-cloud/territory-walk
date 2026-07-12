// このファイルの役割:
// 1回の散歩(スタート〜ストップ)の記録。振り返り画面・バッジ判定の
// どちらからも参照される、散歩履歴の1件分のデータモデル。

import 'track_point.dart';

class WalkRecord {
  final DateTime startedAt;
  final double distanceMeters;
  final double areaSquareMeters;
  final List<TrackPoint> route;

  const WalkRecord({
    required this.startedAt,
    required this.distanceMeters,
    required this.areaSquareMeters,
    required this.route,
  });

  Map<String, dynamic> toJson() => {
        'startedAt': startedAt.toIso8601String(),
        'distanceMeters': distanceMeters,
        'areaSquareMeters': areaSquareMeters,
        'route': route.map((p) => p.toJson()).toList(),
      };

  factory WalkRecord.fromJson(Map<String, dynamic> json) => WalkRecord(
        startedAt: DateTime.parse(json['startedAt'] as String),
        distanceMeters: (json['distanceMeters'] as num).toDouble(),
        areaSquareMeters: (json['areaSquareMeters'] as num).toDouble(),
        route: (json['route'] as List)
            .map((p) => TrackPoint.fromJson(p as Map<String, dynamic>))
            .toList(),
      );
}
