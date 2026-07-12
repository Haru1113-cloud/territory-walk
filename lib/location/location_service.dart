// このファイルの役割:
// GPSモードでの現在地取得(geolocatorパッケージ)のラッパー。
// 権限リクエストとストリーム化のみを担当し、軌跡への追加判定は行わない。

import 'package:geolocator/geolocator.dart';

import '../models/track_point.dart';

class LocationService {
  /// 位置情報の権限を確認し、必要ならユーザーに許可を求める。
  /// 許可されなければ false を返す。
  Future<bool> ensurePermission() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse;
  }

  /// 現在地の更新を[TrackPoint]のストリームとして受け取る。
  Stream<TrackPoint> watchPosition() {
    const settings = LocationSettings(
      accuracy: LocationAccuracy.best,
      distanceFilter: 0,
    );

    return Geolocator.getPositionStream(locationSettings: settings).map(
      (position) => TrackPoint(
        lat: position.latitude,
        lng: position.longitude,
        capturedAt: DateTime.now(),
      ),
    );
  }
}
