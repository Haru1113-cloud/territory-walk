// このファイルの役割:
// 誰が誰に「応援スタンプ」を送ったかを表す最小限のデータモデル。
// 対戦要素ではなく、他ユーザーの頑張りに軽く反応するためだけの機能。

class Cheer {
  final String fromOwnerId;
  final String toOwnerId;

  const Cheer({required this.fromOwnerId, required this.toOwnerId});

  Map<String, dynamic> toJson() => {
        'fromOwnerId': fromOwnerId,
        'toOwnerId': toOwnerId,
      };

  factory Cheer.fromJson(Map<String, dynamic> json) => Cheer(
        fromOwnerId: json['fromOwnerId'] as String,
        toOwnerId: json['toOwnerId'] as String,
      );
}
