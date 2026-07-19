// このファイルの役割:
// アプリ全体の入れ物。下部ナビゲーションバーで「地図」「ランキング」
// 「記録」「バッジ」の4画面を切り替える。IndexedStackで各タブの状態
// (スクロール位置など)をタブ切り替え後も保持する。

import 'package:flutter/material.dart';

import 'badge_screen.dart';
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
    HistoryScreen(),
    BadgeScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _tabs),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        backgroundColor: AppColors.panel,
        indicatorColor: AppColors.trail.withValues(alpha: 0.16),
        destinations: const [
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
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: '記録',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'バッジ',
          ),
        ],
      ),
    );
  }
}
