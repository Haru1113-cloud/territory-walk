// このファイルの役割:
// 軌跡上の1点(緯度経度と取得時刻)を表すデータモデル。計算ロジックは持たない。

class TrackPoint {
  final double lat;
  final double lng;
  final DateTime capturedAt;

  const TrackPoint({
    required this.lat,
    required this.lng,
    required this.capturedAt,
  });

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'capturedAt': capturedAt.toIso8601String(),
      };

  factory TrackPoint.fromJson(Map<String, dynamic> json) => TrackPoint(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        capturedAt: DateTime.parse(json['capturedAt'] as String),
      );
}
