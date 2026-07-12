// このファイルの役割:
// flutter_map本体。確定済み領土ポリゴン・記録中の軌跡・現在地マーカーを描画する。
// 配色・レイヤー順序・ベースマップの選定理由はterritory-rendering skillを参照。

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:provider/provider.dart';

import '../state/territory_walk_controller.dart';
import 'app_style.dart';

// 東京駅付近をデフォルトの初期表示位置とする(現在地が未取得のとき用)。
const _defaultCenter = latlng.LatLng(35.681236, 139.767125);

class TerritoryMap extends StatelessWidget {
  const TerritoryMap({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TerritoryWalkController>();

    return FlutterMap(
      options: MapOptions(
        initialCenter: _defaultCenter,
        initialZoom: 17,
        onTap: (tapPosition, point) {
          controller.addTestPoint(point.latitude, point.longitude);
        },
      ),
      children: [
        // CARTOのPositron(ラベルなし版)。地名・道路名などの文字情報を
        // あえて持たないベースマップにすることで、軌跡と領土の色だけが
        // 目立つすっきりした見た目にする。
        TileLayer(
          urlTemplate:
              'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
          subdomains: const ['a', 'b', 'c', 'd'],
          userAgentPackageName: 'com.territorywalk.territory_walk',
        ),
        PolygonLayer(polygons: _buildTerritoryPolygons(controller)),
        PolylineLayer(polylines: [_buildTrailPolyline(controller)]),
        if (controller.mode == TrackingMode.gps && controller.trail.isNotEmpty)
          MarkerLayer(markers: [_buildCurrentLocationMarker(controller)]),
      ],
    );
  }

  Marker _buildCurrentLocationMarker(TerritoryWalkController controller) {
    final current = controller.trail.last;
    return Marker(
      point: latlng.LatLng(current.lat, current.lng),
      width: 32,
      height: 32,
      child: const Icon(Icons.my_location, color: AppColors.accent),
    );
  }

  List<Polygon> _buildTerritoryPolygons(TerritoryWalkController controller) {
    return controller.territories
        .map(
          (territory) => Polygon(
            points: territory.points
                .map((p) => latlng.LatLng(p.lat, p.lng))
                .toList(),
            color: AppColors.territoryFill.withValues(alpha: 0.55),
            borderColor: AppColors.territoryBorder,
            borderStrokeWidth: 3,
          ),
        )
        .toList();
  }

  Polyline _buildTrailPolyline(TerritoryWalkController controller) {
    return Polyline(
      points:
          controller.trail.map((p) => latlng.LatLng(p.lat, p.lng)).toList(),
      color: AppColors.accent,
      strokeWidth: 6,
      strokeCap: StrokeCap.round,
      strokeJoin: StrokeJoin.round,
    );
  }
}
