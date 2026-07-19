// このファイルの役割:
// アプリのメイン画面(現時点で唯一の画面)。地図を全面に表示し、
// 操作パネルを画面下部にボトムシート状で重ねる。
// バッジ解除の通知(SnackBar)と、領土獲得時の演出(画面上部のトースト)も
// ここで出す(Controllerの状態変化を監視して、表示し終わったらクリアする役目)。

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:provider/provider.dart';

import '../location/location_service.dart';
import '../state/tera_walk_controller.dart';
import '../widgets/app_style.dart';
import '../widgets/control_panel.dart';
import '../widgets/format.dart';
import '../widgets/map_camera_animation.dart';
import '../widgets/map_zoom_controls.dart';
import '../widgets/territory_gain_toast.dart';
import '../widgets/territory_map.dart';

class WalkScreen extends StatefulWidget {
  const WalkScreen({super.key});

  @override
  State<WalkScreen> createState() => _WalkScreenState();
}

class _WalkScreenState extends State<WalkScreen>
    with SingleTickerProviderStateMixin {
  late final TeraWalkController _controller;
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  String? _gainToastMessage;
  Timer? _gainToastTimer;

  @override
  void initState() {
    super.initState();
    _controller = context.read<TeraWalkController>();
    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _gainToastTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  /// 「現在地に戻る」ボタンの処理。記録中かどうかに関わらず常に呼べる
  /// (地図の表示位置を動かすだけで、記録には影響しない)。
  Future<void> _recenterToCurrentLocation() async {
    final granted = await _locationService.ensurePermission();
    if (!mounted) return;
    if (!granted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('位置情報の利用が許可されていません')),
      );
      return;
    }

    final point = await _locationService.getCurrentPosition();
    if (!mounted) return;
    if (point == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('現在地を取得できませんでした')),
      );
      return;
    }

    await animatedMapMove(
      _mapController,
      this,
      destination: latlng.LatLng(point.lat, point.lng),
      destinationZoom: 17,
    );
  }

  /// ニックネームの設定・変更ダイアログを表示する。アカウント登録はせず、
  /// 表示名を端末ローカルに保存するだけ(他ユーザーへの領土公開時に添える)。
  Future<void> _editNickname() async {
    final controller = TextEditingController(text: _controller.nickname ?? '');
    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.panel,
        title: const Text('ニックネーム', style: TextStyle(color: AppColors.ink)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 20,
          style: const TextStyle(color: AppColors.ink),
          decoration: const InputDecoration(hintText: '例: たろう'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(controller.text),
            child: const Text('保存'),
          ),
        ],
      ),
    );

    if (result == null) return;
    await _controller.setNickname(result);
  }

  void _onControllerChanged() {
    _showNewlyUnlockedBadges();
    _showTerritoryGainToast();
  }

  void _showNewlyUnlockedBadges() {
    if (_controller.newlyUnlockedBadges.isEmpty) return;

    for (final badge in _controller.newlyUnlockedBadges) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('バッジ獲得: ${badge.title}')),
      );
    }
    _controller.clearNewlyUnlockedBadges();
  }

  /// 輪が閉じて領土が確定した瞬間、画面上部に「+xxx m² 獲得！」を
  /// 短時間だけ表示する。
  void _showTerritoryGainToast() {
    if (_controller.newlyClosedTerritoryAreas.isEmpty) return;

    final totalArea = _controller.newlyClosedTerritoryAreas
        .fold<double>(0, (sum, area) => sum + area);
    _controller.clearNewlyClosedTerritoryAreas();

    setState(() {
      _gainToastMessage = '+${formatArea(totalArea)} 獲得！';
    });

    _gainToastTimer?.cancel();
    _gainToastTimer = Timer(const Duration(seconds: 3), () {
      if (!mounted) return;
      setState(() => _gainToastMessage = null);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'テラウォーク',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
        backgroundColor: AppColors.background.withValues(alpha: 0.75),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        actions: [
          _AppBarGlassIcon(
            icon: Icons.person_outline,
            tooltip: 'ニックネーム',
            onPressed: _editNickname,
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          TerritoryMap(mapController: _mapController),
          Positioned(
            top: MediaQuery.of(context).padding.top + kToolbarHeight + 12,
            left: 24,
            right: 24,
            child: TerritoryGainToast(message: _gainToastMessage),
          ),
          Positioned(
            right: 16,
            top: 0,
            bottom: 0,
            child: Center(child: MapZoomControls(mapController: _mapController)),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false,
              // 12pxはカード自体の見た目上の余白、bottomNavBarHeightは
              // HomeShellの浮遊ナビゲーションバーに隠れないための余白。
              minimum: const EdgeInsets.fromLTRB(
                16,
                0,
                16,
                12 + AppColors.bottomNavBarHeight,
              ),
              child: ControlPanel(onRecenter: _recenterToCurrentLocation),
            ),
          ),
        ],
      ),
    );
  }
}

/// AppBarのアイコンをガラス風の円で囲む。素のアイコンより存在感と
/// タップしやすさを持たせるための共通ラッパー。
class _AppBarGlassIcon extends StatelessWidget {
  const _AppBarGlassIcon({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.panel,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.border),
        ),
        child: IconButton(
          icon: Icon(icon, color: AppColors.ink, size: 20),
          tooltip: tooltip,
          onPressed: onPressed,
        ),
      ),
    );
  }
}
