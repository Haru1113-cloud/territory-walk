// このファイルの役割:
// 軌跡・領土をネオンのように光らせるための、Polyline/Polygonの重ね合わせ
// ヘルパー。flutter_mapのPolyline/PolygonにはCSSのbox-shadow相当の
// プロパティがないため、太さ・不透明度の異なるレイヤーを複数重ねて
// 「縁が滲んで見える」簡易的なグロー表現を作る(詳細はterritory-rendering
// skillを参照)。

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

/// [points]を通る線に、[color]のグローを付けたPolylineのリストを返す。
/// 呼び出し側はこのリストをそのまま`PolylineLayer.polylines`に渡す
/// (先に描いたものが下、後が上に重なる=外側の光暈を先に描く)。
List<Polyline> buildGlowPolylines({
  required List<LatLng> points,
  required Color color,
  required double coreWidth,
}) {
  return [
    Polyline(
      points: points,
      color: color.withValues(alpha: 0.18),
      strokeWidth: coreWidth * 3,
      strokeCap: StrokeCap.round,
      strokeJoin: StrokeJoin.round,
    ),
    Polyline(
      points: points,
      color: color.withValues(alpha: 0.4),
      strokeWidth: coreWidth * 1.7,
      strokeCap: StrokeCap.round,
      strokeJoin: StrokeJoin.round,
    ),
    Polyline(
      points: points,
      color: color,
      strokeWidth: coreWidth,
      strokeCap: StrokeCap.round,
      strokeJoin: StrokeJoin.round,
    ),
  ];
}

/// [points]で囲まれた領土に、[color]のグローを付けたPolygonのリストを返す。
/// 呼び出し側はこのリストをそのまま`PolygonLayer.polygons`に足し込む。
/// [hitValue]を渡すと、タップ判定(`PolygonLayer.hitNotifier`)でこの値が
/// 拾えるようになる(例: タップした領土の持ち主を特定するため)。
List<Polygon<R>> buildGlowPolygons<R extends Object>({
  required List<LatLng> points,
  required Color color,
  R? hitValue,
}) {
  return [
    Polygon<R>(
      points: points,
      color: Colors.transparent,
      borderColor: color.withValues(alpha: 0.25),
      borderStrokeWidth: 10,
      hitValue: hitValue,
    ),
    Polygon<R>(
      points: points,
      color: color.withValues(alpha: 0.32),
      borderColor: color,
      borderStrokeWidth: 2.5,
      hitValue: hitValue,
    ),
  ];
}
