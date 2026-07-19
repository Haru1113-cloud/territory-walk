// このファイルの役割:
// アプリ全体の状態(モード・記録中軌跡・確定済み領土・合計面積)を1箇所で
// 管理するChangeNotifier。状態管理の方針はflutter-conventions skillを参照。
//
// 幾何計算(距離・面積・輪のクローズ判定)はlib/geo/の純粋関数を呼び出すだけで、
// このファイル自身には数式を書かない。

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../auth/auth_service.dart';
import '../badges/badge.dart';
import '../badges/badge_definitions.dart';
import '../challenges/weekly_challenge.dart';
import '../geo/distance.dart';
import '../geo/loop_detector.dart';
import '../geo/polygon_area.dart';
import '../location/location_service.dart';
import '../models/cheer.dart';
import '../models/ranking_entry.dart';
import '../models/territory.dart';
import '../models/track_point.dart';
import '../models/walk_record.dart';
import '../storage/badge_repository.dart';
import '../storage/cheer_repository.dart';
import '../storage/nickname_repository.dart';
import '../storage/remote_territory_repository.dart';
import '../storage/territory_repository.dart';
import '../storage/walk_history_repository.dart';

class TeraWalkController extends ChangeNotifier {
  TeraWalkController({
    LocationService? locationService,
    TerritoryRepository? repository,
    WalkHistoryRepository? walkHistoryRepository,
    BadgeRepository? badgeRepository,
    RemoteTerritoryRepository? remoteRepository,
    AuthService? authService,
    NicknameRepository? nicknameRepository,
    CheerRepository? cheerRepository,
  })  : _locationService = locationService ?? LocationService(),
        _repository = repository ?? TerritoryRepository(),
        _walkHistoryRepository =
            walkHistoryRepository ?? WalkHistoryRepository(),
        _badgeRepository = badgeRepository ?? BadgeRepository(),
        _remoteRepository = remoteRepository ?? RemoteTerritoryRepository(),
        _authService = authService ?? AuthService(),
        _nicknameRepository = nicknameRepository ?? NicknameRepository(),
        _cheerRepository = cheerRepository ?? CheerRepository() {
    _loadSavedTerritories();
    _loadSavedWalkHistory();
    _loadSavedBadges();
    _loadSavedNickname();
    _watchOthersTerritories();
    _watchCheers();
    _authService.ensureSignedIn().then((uid) => _myOwnerId = uid);
  }

  final LocationService _locationService;
  final TerritoryRepository _repository;
  final WalkHistoryRepository _walkHistoryRepository;
  final BadgeRepository _badgeRepository;
  final RemoteTerritoryRepository _remoteRepository;
  final AuthService _authService;
  final NicknameRepository _nicknameRepository;
  final CheerRepository _cheerRepository;
  StreamSubscription<TrackPoint>? _gpsSubscription;
  StreamSubscription<List<Territory>>? _othersSubscription;
  StreamSubscription<List<Cheer>>? _cheersSubscription;
  String? _myOwnerId;
  final List<Cheer> _cheers = [];

  /// 端末ローカルで設定した表示用ニックネーム(アカウント登録は不要)。
  /// 未設定ならnull。
  String? nickname;

  bool isTracking = false;

  final List<TrackPoint> trail = [];
  final List<Territory> territories = [];

  /// 他ユーザーが公開した領土(閲覧専用。自分の分はここには含まない)。
  final List<Territory> othersTerritories = [];

  /// 今回のスタート〜ストップの間に記録した全ポイント。輪が閉じても
  /// (`trail`と違って)リセットされない。移動距離の計算と、散歩記録の
  /// ルート保存の両方に使う。
  final List<TrackPoint> sessionRoute = [];

  /// 過去の散歩記録(振り返り画面・バッジ判定で使う)。
  final List<WalkRecord> walkHistory = [];

  /// 解除済みバッジのID。
  final Set<String> unlockedBadgeIds = {};

  /// 直近の`stop()`で新たに解除されたバッジ。UI側がトースト表示したら
  /// `clearNewlyUnlockedBadges()`で空にする(1回限りの通知として扱うため)。
  final List<BadgeDefinition> newlyUnlockedBadges = [];

  /// 輪が閉じて領土が確定するたびに追加される、獲得面積の通知キュー。
  /// UI側が獲得演出(トースト)を表示したら`clearNewlyClosedTerritoryAreas()`
  /// で空にする(newlyUnlockedBadgesと同じ「1回限りの通知」の仕組み)。
  final List<double> newlyClosedTerritoryAreas = [];

  double _sessionAreaSquareMeters = 0;
  DateTime? _sessionStartedAt;

  double get totalAreaSquareMeters =>
      territories.fold(0, (sum, t) => sum + t.areaSquareMeters);

  /// 獲得面積の合計でユーザーを降順に並べたランキング。自分の分は
  /// (Firestoreに公開済みかどうかに関わらず)ローカルの`territories`から
  /// 集計するので、公開に失敗していてもランキングには反映される。
  /// 他ユーザーの分は`othersTerritories`(Firestore購読)をownerIdごとに
  /// 集計する。新しいサーバー処理は追加せず、既存の購読データの範囲で
  /// クライアント側で計算するだけにとどめている。
  List<RankingEntry> get ranking => _buildRanking(territories, othersTerritories);

  /// 今週チーム全体でどれだけ獲得したか(自分＋他ユーザーの合計、m²)。
  double get weeklyTeamAreaSquareMeters {
    final now = DateTime.now();
    final mine = territoriesThisWeek(territories, now)
        .fold<double>(0, (sum, t) => sum + t.areaSquareMeters);
    final others = territoriesThisWeek(othersTerritories, now)
        .fold<double>(0, (sum, t) => sum + t.areaSquareMeters);
    return mine + others;
  }

  /// 今週のチーム目標(m²)。
  double get weeklyChallengeTargetAreaSquareMeters =>
      currentWeekTargetAreaSquareMeters(DateTime.now());

  /// 今週分だけに絞った、ユーザーごとの獲得面積ランキング。
  List<RankingEntry> get weeklyChallengeRanking {
    final now = DateTime.now();
    return _buildRanking(
      territoriesThisWeek(territories, now),
      territoriesThisWeek(othersTerritories, now),
    );
  }

  /// [mine]と[others]から、獲得面積の合計でユーザーを降順に並べた
  /// ランキングを作る。`ranking`と`weeklyChallengeRanking`の共通処理。
  List<RankingEntry> _buildRanking(
    List<Territory> mine,
    List<Territory> others,
  ) {
    final byOwner = <String, List<Territory>>{};
    for (final t in others) {
      final ownerId = t.ownerId;
      if (ownerId == null) continue;
      byOwner.putIfAbsent(ownerId, () => []).add(t);
    }

    final entries = byOwner.entries.map((entry) {
      final territoriesForOwner = entry.value;
      return RankingEntry(
        ownerId: entry.key,
        ownerName: territoriesForOwner
            .map((t) => t.ownerName)
            .firstWhere((name) => name != null, orElse: () => null),
        totalAreaSquareMeters: territoriesForOwner.fold(
          0,
          (sum, t) => sum + t.areaSquareMeters,
        ),
        territoryCount: territoriesForOwner.length,
        isMe: false,
      );
    }).toList();

    entries.add(RankingEntry(
      ownerId: _myOwnerId ?? 'me',
      ownerName: nickname,
      totalAreaSquareMeters:
          mine.fold(0, (sum, t) => sum + t.areaSquareMeters),
      territoryCount: mine.length,
      isMe: true,
    ));

    entries.sort(
      (a, b) => b.totalAreaSquareMeters.compareTo(a.totalAreaSquareMeters),
    );
    return entries;
  }

  /// 今回の散歩でここまで歩いた距離。
  double get sessionDistanceMeters => pathDistanceMeters(sessionRoute);

  Future<void> _loadSavedTerritories() async {
    final saved = await _repository.load();
    territories.addAll(saved);
    notifyListeners();
  }

  Future<void> _loadSavedWalkHistory() async {
    final saved = await _walkHistoryRepository.load();
    walkHistory.addAll(saved);
    notifyListeners();
  }

  Future<void> _loadSavedBadges() async {
    final saved = await _badgeRepository.load();
    unlockedBadgeIds.addAll(saved);
    notifyListeners();
  }

  Future<void> _loadSavedNickname() async {
    nickname = await _nicknameRepository.load();
    notifyListeners();
  }

  /// ニックネームを設定・保存する。以後に公開する領土から反映される
  /// (過去に公開済みの領土は遡って更新されない)。
  Future<void> setNickname(String value) async {
    final trimmed = value.trim();
    nickname = trimmed.isEmpty ? null : trimmed;
    await _nicknameRepository.save(nickname);
    notifyListeners();
  }

  /// 他ユーザーの領土をリアルタイムに購読する。取得に失敗しても
  /// (オフライン等)アプリ自体は問題なく使えるようにする。
  void _watchOthersTerritories() {
    _othersSubscription = _remoteRepository.watchAll().listen((all) {
      othersTerritories
        ..clear()
        ..addAll(all.where((t) => t.ownerId != _myOwnerId));
      notifyListeners();
    }, onError: (_) {});
  }

  /// 応援スタンプをリアルタイムに購読する。
  void _watchCheers() {
    _cheersSubscription = _cheerRepository.watchAll().listen((all) {
      _cheers
        ..clear()
        ..addAll(all);
      notifyListeners();
    }, onError: (_) {});
  }

  /// ownerIdごとに受け取った応援スタンプの件数。
  Map<String, int> get cheerCounts {
    final counts = <String, int>{};
    for (final cheer in _cheers) {
      counts[cheer.toOwnerId] = (counts[cheer.toOwnerId] ?? 0) + 1;
    }
    return counts;
  }

  /// [toOwnerId]に応援スタンプを送る。自分自身には送れない。
  /// 送信に失敗しても(オフライン等)UIをフリーズさせない。
  Future<void> sendCheer(String toOwnerId) async {
    try {
      final fromOwnerId = _myOwnerId ?? await _authService.ensureSignedIn();
      _myOwnerId = fromOwnerId;
      if (fromOwnerId == toOwnerId) return;
      await _cheerRepository.send(fromOwnerId: fromOwnerId, toOwnerId: toOwnerId);
    } catch (_) {
      // 失敗しても他の機能には影響させない。
    }
  }

  /// UIがトースト表示し終わったら呼ぶ。呼ばないと同じ通知が残り続ける。
  void clearNewlyUnlockedBadges() {
    newlyUnlockedBadges.clear();
  }

  /// UIが獲得演出を表示し終わったら呼ぶ。
  void clearNewlyClosedTerritoryAreas() {
    newlyClosedTerritoryAreas.clear();
  }

  /// 記録を開始する。現在地の監視を開始する。
  Future<void> start() async {
    if (isTracking) return;

    final granted = await _locationService.ensurePermission();
    if (!granted) return;
    _gpsSubscription = _locationService.watchPosition().listen(_tryAddPoint);

    isTracking = true;
    trail.clear();
    sessionRoute.clear();
    _sessionAreaSquareMeters = 0;
    _sessionStartedAt = DateTime.now();
    notifyListeners();
  }

  /// 記録を停止する。散歩を1件記録として保存し、バッジの達成判定も行う
  /// (散歩記録の詳細はflutter-conventions skillのController節を参照)。
  void stop() {
    isTracking = false;
    _gpsSubscription?.cancel();
    _gpsSubscription = null;
    _finishWalk();
    _evaluateBadges();
    notifyListeners();
  }

  /// 意味のある移動があった散歩だけを記録する(点が1〜2個程度で
  /// スタート直後にストップしたようなケースは記録しない)。
  void _finishWalk() {
    if (sessionRoute.length < 2) return;

    walkHistory.add(WalkRecord(
      startedAt: _sessionStartedAt ?? DateTime.now(),
      distanceMeters: sessionDistanceMeters,
      areaSquareMeters: _sessionAreaSquareMeters,
      route: List.of(sessionRoute),
    ));

    _walkHistoryRepository.save(walkHistory);
  }

  /// 指定した散歩記録に写真(base64)を1枚追加する。
  Future<void> addPhotoToWalk(String walkId, String photoBase64) async {
    final index = walkHistory.indexWhere((r) => r.id == walkId);
    if (index == -1) return;

    final old = walkHistory[index];
    walkHistory[index] = WalkRecord(
      startedAt: old.startedAt,
      distanceMeters: old.distanceMeters,
      areaSquareMeters: old.areaSquareMeters,
      route: old.route,
      photoBase64: [...old.photoBase64, photoBase64],
    );

    await _walkHistoryRepository.save(walkHistory);
    notifyListeners();
  }

  /// 散歩記録・領土の実績から、新たに解除されたバッジがないか判定する。
  void _evaluateBadges() {
    final distinctDays = walkHistory
        .map((r) => DateTime(r.startedAt.year, r.startedAt.month, r.startedAt.day))
        .toSet()
        .length;

    final stats = WalkStats(
      totalWalks: walkHistory.length,
      totalTerritories: territories.length,
      totalDistanceMeters:
          walkHistory.fold(0, (sum, r) => sum + r.distanceMeters),
      distinctWalkDays: distinctDays,
    );

    final newlyUnlocked = evaluateNewlyUnlocked(stats, unlockedBadgeIds);
    if (newlyUnlocked.isEmpty) return;

    unlockedBadgeIds.addAll(newlyUnlocked.map((b) => b.id));
    newlyUnlockedBadges.addAll(newlyUnlocked);
    _badgeRepository.save(unlockedBadgeIds);
  }

  void _tryAddPoint(TrackPoint point) {
    // ブレ除去フィルタはsessionRouteを基準にする。trailは輪が閉じるたびに
    // リセットされるため、それを基準にすると閉じた直後だけフィルタが
    // 効かなくなってしまう。
    if (!shouldAddPoint(sessionRoute, point)) return;

    sessionRoute.add(point);
    trail.add(point);

    if (isLoopClosed(trail)) {
      _closeLoop();
      return;
    }

    // スタート地点まで戻らなくても、ルートが自分自身と交差したらその
    // 内側を輪として確定する。
    final intersectionLoop = findSelfIntersectionLoop(trail);
    if (intersectionLoop != null) {
      trail
        ..clear()
        ..addAll(intersectionLoop);
      _closeLoop();
      return;
    }

    notifyListeners();
  }

  void _closeLoop() {
    if (trail.length < 3) {
      trail.clear();
      notifyListeners();
      return;
    }

    final area = shoelaceAreaSquareMeters(trail);
    final territory = Territory(
      points: List.of(trail),
      areaSquareMeters: area,
      closedAt: DateTime.now(),
    );
    territories.add(territory);
    _sessionAreaSquareMeters += area;
    newlyClosedTerritoryAreas.add(area);
    trail.clear();

    _repository.save(territories);
    _publishToRemote(territory);
    notifyListeners();
  }

  /// 確定した領土を他ユーザーにも見えるようFirestoreへ公開する。
  /// オフラインなど失敗しても、ローカルの記録には影響させない。
  Future<void> _publishToRemote(Territory territory) async {
    try {
      final ownerId = _myOwnerId ?? await _authService.ensureSignedIn();
      _myOwnerId = ownerId;
      await _remoteRepository.publish(territory, ownerId, nickname);
    } catch (_) {
      // 公開に失敗してもローカルの散歩体験は継続できるようにする。
    }
  }

  @override
  void dispose() {
    _gpsSubscription?.cancel();
    _othersSubscription?.cancel();
    _cheersSubscription?.cancel();
    super.dispose();
  }
}
