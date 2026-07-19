// このファイルの役割:
// 確定済みの領土(輪を構成した点の配列と、その面積)を表すデータモデル。

import 'track_point.dart';

class Territory {
  final List<TrackPoint> points;
  final double areaSquareMeters;
  final DateTime closedAt;

  /// 持ち主のユーザーID(FirebaseAuthのuid)。他ユーザーの領土を見分けるために
  /// 使う。ローカルにのみ保存されていた過去データにはこの情報がないため
  /// nullを許容する(自分の領土として扱われる)。
  final String? ownerId;

  const Territory({
    required this.points,
    required this.areaSquareMeters,
    required this.closedAt,
    this.ownerId,
  });

  Map<String, dynamic> toJson() => {
        'points': points.map((p) => p.toJson()).toList(),
        'areaSquareMeters': areaSquareMeters,
        'closedAt': closedAt.toIso8601String(),
        'ownerId': ownerId,
      };

  factory Territory.fromJson(Map<String, dynamic> json) => Territory(
        points: (json['points'] as List)
            .map((p) => TrackPoint.fromJson(p as Map<String, dynamic>))
            .toList(),
        areaSquareMeters: (json['areaSquareMeters'] as num).toDouble(),
        closedAt: DateTime.parse(json['closedAt'] as String),
        ownerId: json['ownerId'] as String?,
      );
}
