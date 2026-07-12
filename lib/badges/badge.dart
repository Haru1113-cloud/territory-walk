// このファイルの役割:
// バッジ(実績)1件の定義を表すデータモデル。達成条件の判定ロジックは
// badge_definitions.dartに置き、ここには見た目・文言の情報だけを持たせる。

import 'package:flutter/material.dart';

class BadgeDefinition {
  final String id;
  final String title;
  final String description;
  final IconData icon;

  const BadgeDefinition({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });
}
