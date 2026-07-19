// このファイルの役割:
// flutter_map本体。確定済み領土ポリゴン・記録中の軌跡・現在地マーカーを描画する。
// 配色・レイヤー順序・ベースマップの選定理由・グロー表現の仕組みは
// territory-rendering skillを参照。

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:provider/provider.dart';

import '../models/territory.dart';
import '../state/tera_walk_controller.dart';
import 'app_style.dart';
import 'glow_line_style.dart';

// 東京駅付近をデフォルトの初期表示位置とする(現在地が未取得のとき用)。
const _defaultCenter = latlng.LatLng(35.681236, 139.767125);

class TerritoryMap extends StatelessWidget {
  const TerritoryMap({super.key, required this.mapController});

  final MapController mapController;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TeraWalkController>();

    // 領土タップで持ち主を表示するためのヒット判定。他ユーザー分→自分の分の
    // 順で1つのPolygonLayerにまとめる(自分の領土が上に重なって見えるよう、
    // 描画順は変えない)。
    final hitNotifier = ValueNotifier<LayerHitResult<Territory>?>(null);
    final territoryPolygons = [
      ..._buildOthersTerritoryPolygons(controller),
      ..._buildTerritoryPolygons(controller),
    ];

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        initialCenter: _defaultCenter,
        initialZoom: 17,
      ),
      children: [
        // CARTOのPositron(ラベルなし版、明るい配色)。「情報を伝える地図」
        // ではなく「柔らかい自然光の下の舞台」にしたいため、明るいタイルを
        // 使う。生のタイルをそのまま見せるのではなく、BlendMode.colorで
        // 単色トーン(mapTint)に染めることで、情報過多な「地図製品」では
        // なく単純化されたフラットな舞台に見せる(明るい基調のタイルで
        // なければ、色を乗せても暗いままになるため明るいタイルが前提)。
        ColorFiltered(
          colorFilter: const ColorFilter.mode(AppColors.mapTint, BlendMode.color),
          child: TileLayer(
            urlTemplate:
                'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
            subdomains: const ['a', 'b', 'c', 'd'],
            retinaMode: RetinaMode.isHighDensity(context),
            userAgentPackageName: 'com.territorywalk.territory_walk',
          ),
        ),
        GestureDetector(
          onTap: () =>
              _handleTerritoryTap(context, controller, hitNotifier.value),
          child: PolygonLayer<Territory>(
            polygons: territoryPolygons,
            hitNotifier: hitNotifier,
          ),
        ),
        PolylineLayer(polylines: _buildTrailPolylines(controller)),
        if (controller.trail.isNotEmpty)
          MarkerLayer(markers: [_buildCurrentLocationMarker(controller)]),
      ],
    );
  }

  /// 領土がタップされたとき、持ち主の名前をSnackBarで表示する。
  /// 何もない場所をタップした場合(hitValuesが空)は何もしない。
  void _handleTerritoryTap(
    BuildContext context,
    TeraWalkController controller,
    LayerHitResult<Territory>? hit,
  ) {
    final hitValues = hit?.hitValues;
    if (hitValues == null || hitValues.isEmpty) return;

    final territory = hitValues.first;
    final isMine = controller.territories.contains(territory);
    final name = isMine
        ? (controller.nickname ?? 'あなた')
        : (territory.ownerName ?? '名無しさん');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$nameの領土')),
    );
  }

  Marker _buildCurrentLocationMarker(TeraWalkController controller) {
    final current = controller.trail.last;
    return Marker(
      point: latlng.LatLng(current.lat, current.lng),
      width: 40,
      height: 40,
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.trail.withValues(alpha: 0.6),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(Icons.my_location, color: AppColors.trail),
      ),
    );
  }

  /// 領土(紫のグロー)を、確定済みの件数分すべて重ねて返す。
  List<Polygon<Territory>> _buildTerritoryPolygons(
    TeraWalkController controller,
  ) {
    return controller.territories.expand((territory) {
      final points =
          territory.points.map((p) => latlng.LatLng(p.lat, p.lng)).toList();
      return buildGlowPolygons<Territory>(
        points: points,
        color: AppColors.territory,
        hitValue: territory,
      );
    }).toList();
  }

  /// 他ユーザーが確定した領土(珊瑚色のグロー)。自分の領土より下に
  /// 描画し、自分の領土がある場所では自分の色が優先して見えるようにする。
  List<Polygon<Territory>> _buildOthersTerritoryPolygons(
    TeraWalkController controller,
  ) {
    return controller.othersTerritories.expand((territory) {
      final points =
          territory.points.map((p) => latlng.LatLng(p.lat, p.lng)).toList();
      return buildGlowPolygons<Territory>(
        points: points,
        color: AppColors.othersTerritory,
        hitValue: territory,
      );
    }).toList();
  }

  /// 記録中の軌跡(ミントのグロー)。
  List<Polyline> _buildTrailPolylines(TeraWalkController controller) {
    final points =
        controller.trail.map((p) => latlng.LatLng(p.lat, p.lng)).toList();
    return buildGlowPolylines(
      points: points,
      color: AppColors.trail,
      coreWidth: 5,
    );
  }
}
