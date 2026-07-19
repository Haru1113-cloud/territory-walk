// このファイルの役割:
// テラウォークのロゴアイコン。「歩いた軌跡(緑の輪)が閉じて領土(紫の塗り)
// になる」というアプリの核心を、シンプルな図形だけで表す。外部の画像
// アセットは使わず、CustomPainterで描画する。

import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'app_style.dart';

class TeraWalkLogo extends StatelessWidget {
  const TeraWalkLogo({super.key, this.size = 28});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _TeraWalkLogoPainter()),
    );
  }
}

class _TeraWalkLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 * 0.68;
    final rect = Rect.fromCircle(center: center, radius: radius);

    // 領土: 輪の内側の塗り。
    final fillPaint = Paint()
      ..color = AppColors.territory.withValues(alpha: 0.35)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, fillPaint);

    // 軌跡: ぐるっと歩いて輪を閉じる途中、というニュアンスを出すために
    // 一周のうち少しだけ隙間を残した円弧にする。
    final trailPaint = Paint()
      ..color = AppColors.trail
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.16
      ..strokeCap = StrokeCap.round;

    const startAngle = -math.pi / 2 + 0.45;
    const sweepAngle = math.pi * 2 - 0.9;
    canvas.drawArc(rect, startAngle, sweepAngle, false, trailPaint);
  }

  @override
  bool shouldRepaint(covariant _TeraWalkLogoPainter oldDelegate) => false;
}
