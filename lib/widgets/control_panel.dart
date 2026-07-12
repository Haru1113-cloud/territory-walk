// このファイルの役割:
// スタート/ストップ・輪を閉じる(手動)ボタンと、軌跡・領土・合計面積の
// ステータス表示を行う操作パネル。画面下部にボトムシート状で固定表示する
// (地図をできるだけ隠さず、親指で操作しやすい位置に置くため)。

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/territory_walk_controller.dart';
import 'app_style.dart';
import 'mode_toggle.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TerritoryWalkController>();

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.panelBackground,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, -4)),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _AreaHero(controller: controller),
          const SizedBox(height: 16),
          const ModeToggle(),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.accent,
                    foregroundColor: Colors.white,
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle:
                        const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  onPressed:
                      controller.isTracking ? controller.stop : controller.start,
                  child: Text(controller.isTracking ? 'ストップ' : 'スタート'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: const BorderSide(color: AppColors.ink, width: 1.5),
                    shape: const StadiumBorder(),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle:
                        const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  onPressed: controller.isTracking
                      ? controller.closeLoopManually
                      : null,
                  child: const Text('輪を閉じる'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AreaHero extends StatelessWidget {
  const _AreaHero({required this.controller});

  final TerritoryWalkController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                '獲得した領土',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 1.2,
                ),
              ),
              Text(
                _formatArea(controller.totalAreaSquareMeters),
                style: const TextStyle(
                  color: AppColors.ink,
                  fontWeight: FontWeight.w900,
                  fontSize: 34,
                  height: 1.1,
                ),
              ),
            ],
          ),
        ),
        Text(
          '軌跡 ${controller.trail.length} / 領土 ${controller.territories.length}件',
          style: const TextStyle(color: Colors.black45, fontSize: 12),
        ),
      ],
    );
  }

  String _formatArea(double squareMeters) {
    if (squareMeters >= 1000000) {
      return '${(squareMeters / 1000000).toStringAsFixed(3)} km²';
    }
    return '${squareMeters.round()} m²';
  }
}
