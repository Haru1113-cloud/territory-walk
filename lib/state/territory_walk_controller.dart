// このファイルの役割:
// アプリ全体の状態(モード・記録中軌跡・確定済み領土・合計面積)を1箇所で
// 管理するChangeNotifier。状態管理の方針はflutter-conventions skillを参照。
//
// 幾何計算(距離・面積・輪のクローズ判定)はlib/geo/の純粋関数を呼び出すだけで、
// このファイル自身には数式を書かない。

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../geo/loop_detector.dart';
import '../geo/polygon_area.dart';
import '../location/location_service.dart';
import '../models/territory.dart';
import '../models/track_point.dart';
import '../storage/territory_repository.dart';

enum TrackingMode { test, gps }

class TerritoryWalkController extends ChangeNotifier {
  TerritoryWalkController({
    LocationService? locationService,
    TerritoryRepository? repository,
  })  : _locationService = locationService ?? LocationService(),
        _repository = repository ?? TerritoryRepository() {
    _loadSavedTerritories();
  }

  final LocationService _locationService;
  final TerritoryRepository _repository;
  StreamSubscription<TrackPoint>? _gpsSubscription;

  TrackingMode mode = TrackingMode.test;
  bool isTracking = false;

  final List<TrackPoint> trail = [];
  final List<Territory> territories = [];

  double get totalAreaSquareMeters =>
      territories.fold(0, (sum, t) => sum + t.areaSquareMeters);

  Future<void> _loadSavedTerritories() async {
    final saved = await _repository.load();
    territories.addAll(saved);
    notifyListeners();
  }

  /// モードを切り替える。記録中は切り替えられない。
  void setMode(TrackingMode newMode) {
    if (isTracking) return;
    mode = newMode;
    notifyListeners();
  }

  /// 記録を開始する。GPSモードなら現在地の監視も開始する。
  Future<void> start() async {
    if (isTracking) return;

    if (mode == TrackingMode.gps) {
      final granted = await _locationService.ensurePermission();
      if (!granted) return;
      _gpsSubscription =
          _locationService.watchPosition().listen(_tryAddPoint);
    }

    isTracking = true;
    trail.clear();
    notifyListeners();
  }

  /// 記録を停止する。
  void stop() {
    isTracking = false;
    _gpsSubscription?.cancel();
    _gpsSubscription = null;
    notifyListeners();
  }

  /// テストモード: 地図タップで軌跡ポイントを追加する。
  void addTestPoint(double lat, double lng) {
    if (!isTracking || mode != TrackingMode.test) return;
    _tryAddPoint(TrackPoint(lat: lat, lng: lng, capturedAt: DateTime.now()));
  }

  void _tryAddPoint(TrackPoint point) {
    if (!shouldAddPoint(trail, point)) return;

    trail.add(point);

    if (isLoopClosed(trail)) {
      _closeLoop();
      return;
    }

    notifyListeners();
  }

  /// 輪を手動で閉じる(テストモードで、歩いて戻らずに確定させたい場合に使う)。
  void closeLoopManually() {
    if (!isTracking) return;
    _closeLoop();
  }

  void _closeLoop() {
    if (trail.length < 3) {
      trail.clear();
      notifyListeners();
      return;
    }

    final area = shoelaceAreaSquareMeters(trail);
    territories.add(Territory(
      points: List.of(trail),
      areaSquareMeters: area,
      closedAt: DateTime.now(),
    ));
    trail.clear();

    _repository.save(territories);
    notifyListeners();
  }

  @override
  void dispose() {
    _gpsSubscription?.cancel();
    super.dispose();
  }
}
