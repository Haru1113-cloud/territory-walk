// このファイルの役割:
// 振り返り画面の2段階目。1件の散歩記録(WalkRecord)のルートを
// 地図上に再描画し、日時・距離・面積を表示する。

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;

import '../models/walk_record.dart';
import '../widgets/app_style.dart';
import '../widgets/format.dart';
import '../widgets/glow_line_style.dart';

class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({super.key, required this.record});

  final WalkRecord record;

  @override
  Widget build(BuildContext context) {
    final routePoints =
        record.route.map((p) => latlng.LatLng(p.lat, p.lng)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(formatDateTime(record.startedAt))),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: routePoints.first,
                initialZoom: 16,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://{s}.basemaps.cartocdn.com/dark_nolabels/{z}/{x}/{y}{r}.png',
                  subdomains: const ['a', 'b', 'c', 'd'],
                  retinaMode: RetinaMode.isHighDensity(context),
                  userAgentPackageName: 'com.territorywalk.territory_walk',
                ),
                PolylineLayer(
                  polylines: buildGlowPolylines(
                    points: routePoints,
                    color: AppColors.trail,
                    coreWidth: 5,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(label: '距離', value: formatDistance(record.distanceMeters)),
                _StatItem(
                  label: '獲得面積',
                  value: record.areaSquareMeters > 0
                      ? formatArea(record.areaSquareMeters)
                      : 'なし',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.inkMuted, fontSize: 12)),
        Text(value,
            style: const TextStyle(
                color: AppColors.ink,
                fontSize: 20,
                fontWeight: FontWeight.w700)),
      ],
    );
  }
}
