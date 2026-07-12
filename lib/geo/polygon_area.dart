// このファイルの役割:
// 緯度経度の軌跡から、局所平面座標への変換と靴ひも公式による面積計算を行う。
// 詳細は geo-math skillを参照。

import 'dart:math';

import '../models/track_point.dart';

class _LocalXY {
  final double x;
  final double y;
  const _LocalXY(this.x, this.y);
}

/// origin(基準点)からの相対距離(メートル)のXY平面座標に変換する。
/// 数百m〜数km程度の散歩コースを想定した局所近似。
_LocalXY _toLocalXY(TrackPoint point, TrackPoint origin) {
  const metersPerDegLat = 111320.0;
  final metersPerDegLng = 111320.0 * cos(origin.lat * pi / 180);

  return _LocalXY(
    (point.lng - origin.lng) * metersPerDegLng,
    (point.lat - origin.lat) * metersPerDegLat,
  );
}

/// 靴ひも公式(Shoelace formula)で、軌跡が囲む面積(平方メートル)を求める。
/// [trail]は閉じていない配列でよい(最後と最初をつなぐ前提で計算する)。
double shoelaceAreaSquareMeters(List<TrackPoint> trail) {
  final origin = trail.first;
  final xyPoints = trail.map((p) => _toLocalXY(p, origin)).toList();

  var sum = 0.0;
  for (var i = 0; i < xyPoints.length; i++) {
    final current = xyPoints[i];
    final next = xyPoints[(i + 1) % xyPoints.length];
    sum += current.x * next.y - next.x * current.y;
  }

  return sum.abs() / 2;
}
