// このファイルの役割:
// スタート/ストップ・輪を閉じる(手動)ボタンと、軌跡・領土・合計面積の
// ステータス表示を行う操作パネル。画面下部にボトムシート状で固定表示する
// (地図をできるだけ隠さず、親指で操作しやすい位置に置くため)。

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/tera_walk_controller.dart';
import 'app_style.dart';
import 'badge_chip_row.dart';
import 'format.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TeraWalkController>();

    // 暗い半透明のガラス調パネル。BackdropFilterで背後の地図を
    // ぼかして重ねることで「フロストガラスの上にUIが乗っている」
    // 見た目にする。
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(
        top: Radius.circular(AppColors.radiusLarge),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(AppColors.radiusLarge),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black45,
                blurRadius: 24,
                offset: Offset(0, -4),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DistanceHero(controller: controller),
              const SizedBox(height: 12),
              const BadgeChipRow(),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _GlowButton(
                      label: controller.isTracking ? 'ストップ' : 'スタート',
                      color: AppColors.trail,
                      fontSize: 16,
                      onPressed: controller.isTracking
                          ? controller.stop
                          : controller.start,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _GlowButton(
                      label: '輪を閉じる',
                      color: AppColors.territory,
                      fontSize: 14,
                      onPressed: controller.isTracking
                          ? controller.closeLoopManually
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// アクセントカラーで塗った、軽くグロー(光彩)が付くボタン。
/// 「押したくなる見た目」にするため、ボタンの下にぼかした同色の影を
/// 敷いて浮かび上がらせる。無効時はグローを弱めて「押せない」ことも
/// 見た目で伝える。
class _GlowButton extends StatelessWidget {
  const _GlowButton({
    required this.label,
    required this.color,
    required this.onPressed,
    required this.fontSize,
  });

  final String label;
  final Color color;
  final VoidCallback? onPressed;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppColors.radiusSmall),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: enabled ? 0.55 : 0.15),
            blurRadius: enabled ? 18 : 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: color,
          foregroundColor: AppColors.onAccent,
          disabledBackgroundColor: color.withValues(alpha: 0.25),
          disabledForegroundColor: AppColors.inkMuted,
          overlayColor: AppColors.onAccent.withValues(alpha: 0.15),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.radiusSmall),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: fontSize),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}

/// 「今回の散歩」の移動距離を主役として大きく見せる。軌跡と同じミント系の
/// 明るい色＋軽いグローを乗せ、パネルの中で一番目を引くようにする。
/// 獲得面積は脇役として下に小さく・控えめな色で添えるだけにする
/// (ユーザー要望: 距離を主役、面積は補助情報に)。
class _DistanceHero extends StatelessWidget {
  const _DistanceHero({required this.controller});

  final TeraWalkController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '今回の散歩の距離',
          style: TextStyle(
            color: AppColors.inkMuted,
            fontWeight: FontWeight.w700,
            fontSize: 13,
            letterSpacing: 0.5,
          ),
        ),
        Text(
          formatDistance(controller.sessionDistanceMeters),
          style: TextStyle(
            color: AppColors.trail,
            fontWeight: FontWeight.w800,
            fontSize: 42,
            letterSpacing: 0.01,
            height: 1.2,
            shadows: [
              Shadow(
                color: AppColors.trail.withValues(alpha: 0.7),
                blurRadius: 18,
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '獲得面積(累計) ${formatArea(controller.totalAreaSquareMeters)} '
          '・軌跡 ${controller.trail.length} / 領土 ${controller.territories.length}件',
          style: const TextStyle(color: AppColors.inkMuted, fontSize: 12),
        ),
      ],
    );
  }
}
