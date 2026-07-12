// このファイルの役割:
// 領土を確定した瞬間に画面上部へ短時間表示する、獲得演出のトースト。
// Material標準のSnackBar(画面下部)ではなく、画面上部に出したいという
// 要望のための軽量な自作ウィジェット(新しい依存パッケージは使わない)。

import 'package:flutter/material.dart';

import 'app_style.dart';

class TerritoryGainToast extends StatelessWidget {
  const TerritoryGainToast({super.key, required this.message});

  /// 表示するメッセージ。nullなら非表示(サイズ0)にする。
  final String? message;

  @override
  Widget build(BuildContext context) {
    final visible = message != null;

    return IgnorePointer(
      child: AnimatedSlide(
        offset: visible ? Offset.zero : const Offset(0, -0.6),
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: AnimatedOpacity(
          opacity: visible ? 1 : 0,
          duration: const Duration(milliseconds: 250),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppColors.territory,
              borderRadius: BorderRadius.circular(AppColors.radiusSmall),
              boxShadow: [
                BoxShadow(
                  color: AppColors.territory.withValues(alpha: 0.6),
                  blurRadius: 20,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Text(
              message ?? '',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.onAccent,
                fontWeight: FontWeight.w800,
                fontSize: 16,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
