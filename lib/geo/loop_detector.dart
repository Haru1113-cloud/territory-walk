// このファイルの役割:
// 新しい位置情報を1点受け取るたびに、
//   (1) GPSのブレ除去フィルタ(直前の点に近すぎる点は無視)
//   (2) 輪の自動クローズ判定(スタート地点に十分近づいたか)
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
