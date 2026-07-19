// このファイルの役割:
// ランキング画面で使う、1ユーザー分の集計結果(合計獲得面積・領土数)。

class RankingEntry {
  final String ownerId;
  final String? ownerName;
  final double totalAreaSquareMeters;
  final int territoryCount;
  final bool isMe;

  const RankingEntry({
    required this.ownerId,
    required this.ownerName,
    required this.totalAreaSquareMeters,
    required this.territoryCount,
    required this.isMe,
  });
}
