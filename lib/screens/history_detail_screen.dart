// このファイルの役割:
// 振り返り画面の2段階目。1件の散歩記録(WalkRecord)のルートを
// 地図上に再描画し、日時・距離・面積・添付写真を表示する。

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:provider/provider.dart';

import '../models/walk_record.dart';
import '../state/tera_walk_controller.dart';
import '../widgets/app_style.dart';
import '../widgets/format.dart';
import '../widgets/glow_line_style.dart';

class HistoryDetailScreen extends StatelessWidget {
  const HistoryDetailScreen({super.key, required this.record});

  final WalkRecord record;

  Future<void> _addPhoto(BuildContext context) async {
    final controller = context.read<TeraWalkController>();
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1280,
      imageQuality: 70,
    );
    if (picked == null) return;

    final bytes = await picked.readAsBytes();
    await controller.addPhotoToWalk(record.id, base64Encode(bytes));
  }

  @override
  Widget build(BuildContext context) {
    // 写真追加後もこの画面に反映されるよう、渡された記録のIDで最新の
    // WalkRecordを引き直す(見つからない場合は渡された値をそのまま使う)。
    final walkHistory = context.watch<TeraWalkController>().walkHistory;
    final current = walkHistory.firstWhere(
      (r) => r.id == record.id,
      orElse: () => record,
    );

    final routePoints =
        current.route.map((p) => latlng.LatLng(p.lat, p.lng)).toList();

    return Scaffold(
      appBar: AppBar(title: Text(formatDateTime(current.startedAt))),
      body: ListView(
        children: [
          SizedBox(
            height: 280,
            child: FlutterMap(
              options: MapOptions(
                initialCenter: routePoints.first,
                initialZoom: 16,
              ),
              children: [
                ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    AppColors.mapTint,
                    BlendMode.color,
                  ),
                  child: TileLayer(
                    urlTemplate:
                        'https://{s}.basemaps.cartocdn.com/light_nolabels/{z}/{x}/{y}{r}.png',
                    subdomains: const ['a', 'b', 'c', 'd'],
                    retinaMode: RetinaMode.isHighDensity(context),
                    userAgentPackageName: 'com.territorywalk.territory_walk',
                  ),
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
                _StatItem(label: '距離', value: formatDistance(current.distanceMeters)),
                _StatItem(
                  label: '獲得面積',
                  value: current.areaSquareMeters > 0
                      ? formatArea(current.areaSquareMeters)
                      : 'なし',
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      '写真',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _addPhoto(context),
                      icon: const Icon(Icons.add_a_photo_outlined, size: 18),
                      label: const Text('写真を追加'),
                    ),
                  ],
                ),
                if (current.photoBase64.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'まだ写真がありません',
                      style: TextStyle(color: AppColors.inkMuted, fontSize: 13),
                    ),
                  )
                else
                  SizedBox(
                    height: 96,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: current.photoBase64.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(width: 8),
                      itemBuilder: (context, index) {
                        return ClipRRect(
                          borderRadius:
                              BorderRadius.circular(AppColors.radiusSmall),
                          child: Image.memory(
                            base64Decode(current.photoBase64[index]),
                            width: 96,
                            height: 96,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
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
