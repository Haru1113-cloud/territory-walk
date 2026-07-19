// このファイルの役割:
// 1回の散歩(スタート〜ストップ)の記録。振り返り画面・バッジ判定の
// どちらからも参照される、散歩履歴の1件分のデータモデル。

import 'track_point.dart';

class WalkRecord {
  final DateTime startedAt;
  final double distanceMeters;
  final double areaSquareMeters;
  final List<TrackPoint> route;

  /// この散歩に添付した写真(base64エンコード済みのJPEG)。
  /// ファイルパスではなくデータそのものを持つことで、web/iOS/Androidの
  /// ファイルシステムの違いを気にせず同じJSON永続化に載せられる。
  final List<String> photoBase64;

  const WalkRecord({
    required this.startedAt,
    required this.distanceMeters,
    required this.areaSquareMeters,
    required this.route,
    this.photoBase64 = const [],
  });

  /// この散歩を一意に識別するID。開始時刻(マイクロ秒)から作る
  /// (同一端末・同一ユーザーの範囲でしか一意性を要求しないため、
  /// UUID等の追加パッケージは使わない)。
  String get id => startedAt.microsecondsSinceEpoch.toString();

  Map<String, dynamic> toJson() => {
        'startedAt': startedAt.toIso8601String(),
        'distanceMeters': distanceMeters,
        'areaSquareMeters': areaSquareMeters,
        'route': route.map((p) => p.toJson()).toList(),
        'photoBase64': photoBase64,
      };

  factory WalkRecord.fromJson(Map<String, dynamic> json) => WalkRecord(
        startedAt: DateTime.parse(json['startedAt'] as String),
        distanceMeters: (json['distanceMeters'] as num).toDouble(),
        areaSquareMeters: (json['areaSquareMeters'] as num).toDouble(),
        route: (json['route'] as List)
            .map((p) => TrackPoint.fromJson(p as Map<String, dynamic>))
            .toList(),
        photoBase64: (json['photoBase64'] as List?)
                ?.map((e) => e as String)
                .toList() ??
            const [],
      );
}
