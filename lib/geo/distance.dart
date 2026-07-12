// このファイルの役割:
// ハバーサイン公式による2点間の距離計算。詳細は geo-math skillを参照。

import 'dart:math';

import '../models/track_point.dart';

/// 地球を半径6371kmの球とみなした、2点間の距離(メートル)を返す。
double haversineDistanceMeters(TrackPoint a, TrackPoint b) {
  const earthRadiusMeters = 6371000.0;
  double toRad(double deg) => deg * pi / 180;

  final dLat = toRad(b.lat - a.lat);
  final dLng = toRad(b.lng - a.lng);
  final lat1 = toRad(a.lat);
  final lat2 = toRad(b.lat);

  final h = pow(sin(dLat / 2), 2) + cos(lat1) * cos(lat2) * pow(sin(dLng / 2), 2);
  final c = 2 * atan2(sqrt(h), sqrt(1 - h));

  return earthRadiusMeters * c;
}
