// このファイルの役割:
// 距離・面積などをユーザー向けの文字列に変換する共通フォーマット関数。
// 操作パネル・振り返り画面など複数箇所で同じ表記を使うためにここへ集約する。

String formatDistance(double meters) {
  if (meters >= 1000) {
    return '${(meters / 1000).toStringAsFixed(2)} km';
  }
  return '${meters.round()} m';
}

String formatArea(double squareMeters) {
  if (squareMeters >= 1000000) {
    return '${(squareMeters / 1000000).toStringAsFixed(3)} km²';
  }
  return '${squareMeters.round()} m²';
}

String _twoDigits(int value) => value.toString().padLeft(2, '0');

/// 日付のみ(振り返り画面の一覧表示用)。intlパッケージは使わず、
/// このアプリで必要な最低限のフォーマットだけ自前で組み立てる。
String formatDate(DateTime dateTime) {
  return '${dateTime.year}/${_twoDigits(dateTime.month)}/${_twoDigits(dateTime.day)}';
}

/// 日付+時刻(振り返り詳細画面用)。
String formatDateTime(DateTime dateTime) {
  return '${formatDate(dateTime)} ${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}';
}
