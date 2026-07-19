// このファイルの役割:
// アプリ全体の入れ物。下部ナビゲーションバーで各画面を切り替える。
// IndexedStackで各タブの状態(スクロール位置など)をタブ切り替え後も保持する。
// ナビゲーションバーは画面の下端に張り付けず、少し余白を持たせて浮かせた
// 丸型のバーとして表示する(ユーザー要望による見た目)。

import 'package:flutter/material.dart';

import 'badge_screen.dart';
import 'challenge_screen.dart';
import 'history_screen.dart';
import 'ranking_screen.dart';
import 'walk_screen.dart';
import '../widgets/app_style.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _selectedIndex = 0;

  static const _tabs = [
    WalkScreen(),
    RankingScreen(),
    ChallengeScreen(),
    HistoryScreen(),
    BadgeScreen(),
  ];

  static const _destinations = [
    NavigationDestination(
      icon: Icon(Icons.map_outlined),
      selectedIcon: Icon(Icons.map),
      label: '地図',
    ),
    NavigationDestination(
      icon: Icon(Icons.leaderboard_outlined),
      selectedIcon: Icon(Icons.leaderboard),
      label: 'ランキング',
    ),
    NavigationDestination(
      icon: Icon(Icons.flag_outlined),
      selectedIcon: Icon(Icons.flag),
      label: 'チャレンジ',
    ),
    NavigationDestination(
      icon: Icon(Icons.calendar_month_outlined),
      selectedIcon: Icon(Icons.calendar_month),
      label: '記録',
    ),
    NavigationDestination(
      icon: Icon(Icons.emoji_events_outlined),
      selectedIcon: Icon(Icons.emoji_events),
      label: 'バッジ',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: Material(
          color: AppColors.panel,
          elevation: 8,
          shadowColor: Colors.black45,
          borderRadius: BorderRadius.circular(28),
          clipBehavior: Clip.antiAlias,
          child: NavigationBar(
            height: 64,
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) =>
                setState(() => _selectedIndex = index),
            backgroundColor: Colors.transparent,
            indicatorColor: AppColors.trail.withValues(alpha: 0.16),
            destinations: _destinations,
          ),
        ),
      ),
    );
  }
}
