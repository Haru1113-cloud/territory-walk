// このファイルの役割:
// アプリのメイン画面(現時点で唯一の画面)。地図を全面に表示し、
// 操作パネルを画面下部にボトムシート状で重ねる。

import 'package:flutter/material.dart';

import '../widgets/app_style.dart';
import '../widgets/control_panel.dart';
import '../widgets/territory_map.dart';

class WalkScreen extends StatelessWidget {
  const WalkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'テリトリー散歩',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w800),
        ),
        backgroundColor: Colors.white.withValues(alpha: 0.9),
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      body: const Stack(
        children: [
          TerritoryMap(),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(top: false, child: ControlPanel()),
          ),
        ],
      ),
    );
  }
}
