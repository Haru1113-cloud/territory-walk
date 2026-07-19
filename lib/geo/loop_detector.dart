// このファイルの役割:
// 新しい位置情報を1点受け取るたびに、
//   (1) GPSのブレ除去フィルタ(直前の点に近すぎる点は無視)
//   (2) 輪の自動クローズ判定(スタート地点に十分近づいたか)
//   (3) 軌跡の自己交差判定(ルートが自分自身と交差したか)
// を行う。数式・閾値の根拠は geo-math skillを参照。

import '../models/track_point.dart';
import 'distance.dart';
import 'territory_constants.dart';

/// 新しい点[candidate]を軌跡[trail]に追加すべきか判定する。
/// 直前の点との距離が[minMoveMeters]未満(GPSのブレ)なら追加しない。
bool shouldAddPoint(List<TrackPoint> trail, TrackPoint candidate) {
  if (trail.isEmpty) return true;
  final last = trail.last;
  return haversineDistanceMeters(last, candidate) >= minMoveMeters;
}

/// 軌跡[trail](新しい点を追加済みの状態)が輪として閉じたかを判定する。
/// ポイント数が[minPointsToClose]以上、かつ最後の点とスタート地点との
/// 距離が[closeRadiusMeters]未満であれば閉じたとみなす。
bool isLoopClosed(List<TrackPoint> trail) {
  if (trail.length < minPointsToClose) return false;
  final start = trail.first;
  final current = trail.last;
  return haversineDistanceMeters(current, start) < closeRadiusMeters;
}

/// 軌跡[trail](新しい点を追加済みの状態)の最新区間が、それより前の
/// (隣接しない)区間と交差していないか調べる。交差していれば、交点を
/// 起点とする新しい輪(そのまま`trail`として使える点列)を返す。
/// 交差していなければnullを返す。
///
/// 交差より前の「しっぽ」部分(交点に至るまでの助走区間)は輪に含めない
/// (`geo-math` skillの自己交差判定の節を参照)。
List<TrackPoint>? findSelfIntersectionLoop(List<TrackPoint> trail) {
  if (trail.length < 4) return null;

  final newStart = trail[trail.length - 2];
  final newEnd = trail[trail.length - 1];

  // 直前の区間(1つ前)は端点を共有していて必ず「交差」してしまうため、
  // 判定対象から除く。
  for (var i = 0; i < trail.length - 3; i++) {
    final intersection =
        _segmentIntersection(trail[i], trail[i + 1], newStart, newEnd);
    if (intersection == null) continue;
    return [intersection, ...trail.sublist(i + 1)];
  }
  return null;
}

/// 線分a-bと線分c-dの交点を返す。端点で接するだけ(t,uが0または1)の
/// 場合や平行な場合はnull。緯度経度をそのまま平面座標とみなして計算する
/// (交差の有無・位置を求めるだけなら、地図投影の歪みは問題にならない)。
TrackPoint? _segmentIntersection(
  TrackPoint a,
  TrackPoint b,
  TrackPoint c,
  TrackPoint d,
) {
  final rX = b.lng - a.lng;
  final rY = b.lat - a.lat;
  final sX = d.lng - c.lng;
  final sY = d.lat - c.lat;

  final denominator = rX * sY - rY * sX;
  if (denominator == 0) return null; // 平行(または重なる)

  final cmpX = c.lng - a.lng;
  final cmpY = c.lat - a.lat;

  final t = (cmpX * sY - cmpY * sX) / denominator;
  final u = (cmpX * rY - cmpY * rX) / denominator;

  if (t <= 0 || t >= 1 || u <= 0 || u >= 1) return null;

  return TrackPoint(
    lat: a.lat + t * rY,
    lng: a.lng + t * rX,
    capturedAt: DateTime.now(),
  );
}
