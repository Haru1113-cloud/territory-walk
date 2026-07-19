// このファイルの役割:
// スタートボタンと、軌跡・領土・合計面積のステータス表示を行う操作パネル。
// 画面下部に、地図から少し浮かせた1枚のカードとして固定表示する
// (地図をできるだけ隠さず、親指で操作しやすい位置に置くため)。
// あえてボトムシート然とした「上端のみ角丸+ドラッグハンドル」にはせず、
// ドラッグでは閉じない普通のカードだと一目でわかる見た目にしている
// (ユーザー要望: 下にスクロール/ドラッグできそうに見えるのを避けたい)。

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/tera_walk_controller.dart';
import 'app_style.dart';
import 'badge_chip_row.dart';
import 'format.dart';

class ControlPanel extends StatelessWidget {
  const ControlPanel({super.key, required this.onRecenter});

  /// 「現在地に戻る」ボタンが押されたときのコールバック。
  final VoidCallback onRecenter;

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<TeraWalkController>();

    // 暗い半透明のガラス調パネル。BackdropFilterで背後の地図を
    // ぼかして重ねることで「フロストガラスの上にUIが乗っている」
    // 見た目にする。四辺とも角丸にして、画面に張り付くボトムシートでは
    // なく独立した1枚のカードに見えるようにする。
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppColors.radiusLarge),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.panel,
            borderRadius: BorderRadius.circular(AppColors.radiusLarge),
            border: Border.all(color: AppColors.border),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _DistanceHero(controller: controller, onRecenter: onRecenter),
              const SizedBox(height: 12),
              const BadgeChipRow(),
              const SizedBox(height: 12),
              _GlowButton(
                label: controller.isTracking ? 'ストップ' : 'スタート',
                color: AppColors.trail,
                fontSize: 16,
                onPressed:
                    controller.isTracking ? controller.stop : controller.start,
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

/// 地図を現在地までアニメーション付きで移動させる、小さな丸型ボタン。
/// 「今動いている・進んでいる」ことに関わる操作なので、スタートボタンと
/// 同じtrail(ミント)色のグローで揃える。
class _RecenterButton extends StatelessWidget {
  const _RecenterButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: AppColors.trail.withValues(alpha: 0.55),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Material(
        color: AppColors.trail,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: const Padding(
            padding: EdgeInsets.all(8),
            child: Icon(
              Icons.navigation,
              color: AppColors.onAccent,
              size: 18,
            ),
          ),
        ),
      ),
    );
  }
}

/// 「今回の散歩」の移動距離を主役として大きく見せる。軌跡と同じミント系の
/// 明るい色＋軽いグローを乗せ、パネルの中で一番目を引くようにする。
/// 獲得面積は脇役として下に小さく・控えめな色で添えるだけにする
/// (ユーザー要望: 距離を主役、面積は補助情報に)。
class _DistanceHero extends StatelessWidget {
  const _DistanceHero({required this.controller, required this.onRecenter});

  final TeraWalkController controller;
  final VoidCallback onRecenter;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(
              child: Text(
                '今回の散歩の距離',
                style: TextStyle(
                  color: AppColors.inkMuted,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            _RecenterButton(onPressed: onRecenter),
          ],
        ),
        Text(
          formatDistance(controller.sessionDistanceMeters),
          style: const TextStyle(
            color: AppColors.trail,
            fontWeight: FontWeight.w800,
            fontSize: 42,
            letterSpacing: 0.01,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _StatChip(
              icon: Icons.hexagon_outlined,
              color: AppColors.territory,
              value: formatArea(controller.totalAreaSquareMeters),
              label: '獲得面積(累計)',
            ),
            _StatChip(
              icon: Icons.timeline,
              color: AppColors.trail,
              value: '${controller.trail.length}',
              label: '軌跡',
            ),
            _StatChip(
              icon: Icons.flag_outlined,
              color: AppColors.territory,
              value: '${controller.territories.length}件',
              label: '領土',
            ),
          ],
        ),
      ],
    );
  }
}

/// 統計を1件ずつ表示する小さなピル型チップ。長い一行のテキストより
/// 一目で数値が拾えるよう、参考にしたUIの統計カードの見た目に寄せた。
class _StatChip extends StatelessWidget {
  const _StatChip({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.background.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.ink,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 3),
          Text(
            label,
            style: const TextStyle(color: AppColors.inkMuted, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
