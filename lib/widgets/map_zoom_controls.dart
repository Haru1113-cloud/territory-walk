// このファイルの役割:
// 地図に重ねて浮かせる、拡大/縮小のガラス風コントロール。
// 「現在地に戻る」ボタン(アクセントカラーで塗った主役級の操作)とは
// 対照的に、頻繁に触る地味な操作なのでニュートラルなガラス面にする。

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

import 'app_style.dart';

class MapZoomControls extends StatelessWidget {
  const MapZoomControls({super.key, required this.mapController});

  final MapController mapController;

  void _zoomBy(double delta) {
    final camera = mapController.camera;
    mapController.move(camera.center, camera.zoom + delta);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppColors.radiusSmall),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ZoomButton(icon: Icons.add, onPressed: () => _zoomBy(1)),
          Container(height: 1, color: AppColors.border),
          _ZoomButton(icon: Icons.remove, onPressed: () => _zoomBy(-1)),
        ],
      ),
    );
  }
}

class _ZoomButton extends StatelessWidget {
  const _ZoomButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, color: AppColors.ink, size: 20),
        ),
      ),
    );
  }
}
