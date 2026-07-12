// このファイルの役割:
// テストモード/GPSモードを切り替えるトグルボタン。記録中は切り替え不可。

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/territory_walk_controller.dart';
import 'app_style.dart';

class ModeToggle extends StatelessWidget {
  const ModeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TerritoryWalkController>();

    return SegmentedButton<TrackingMode>(
      style: SegmentedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.radiusSmall),
        ),
        selectedBackgroundColor: AppColors.primary,
        selectedForegroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        side: const BorderSide(color: AppColors.border, width: 1.5),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
      showSelectedIcon: false,
      segments: const [
        ButtonSegment(
          value: TrackingMode.test,
          label: Text('テストモード'),
          icon: Icon(Icons.touch_app),
        ),
        ButtonSegment(
          value: TrackingMode.gps,
          label: Text('GPSモード'),
          icon: Icon(Icons.gps_fixed),
        ),
      ],
      selected: {controller.mode},
      onSelectionChanged: controller.isTracking
          ? null
          : (selection) => controller.setMode(selection.first),
    );
  }
}
