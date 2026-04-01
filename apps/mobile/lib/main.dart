// Назначение файла: собрать мобильный MVP-клиент с экранами, состоянием, API/WebSocket и игровыми досками двух демо-игр.
// Роль в проекте: быть основной точкой входа Flutter-приложения и связывать UX-сценарии auth/home/catalog/room/store/settings.
// Основные функции: управление AppState, i18n RU/EN, room flow, board widgets для tile/roll-write, локальные боты easy/normal.
// Связи с другими файлами: использует i18n/strings.dart, services/api_client.dart, services/ws_client.dart и theme/tokens.dart.
// Важно при изменении: держать сетевую логику в AppState/сервисах и не переносить сервер-правила напрямую в UI без синхронизации с backend.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:animations/animations.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

import 'i18n/strings.dart';
import 'services/api_client.dart';
import 'services/analytics_client.dart';
import 'services/ws_client.dart';
import 'shared/assets/runtime_asset_pack.dart';
import 'shared/ui/controls.dart';
import 'shared/ui/ui_kit.dart';
import 'shared/ui/system_states.dart';
import 'theme/tokens.dart';
import 'theme/game/big_walker_tokens.dart';
import 'games/big_walker/big_walker_board.dart';
import 'features/gameplay/big_walker/big_walker_match_state.dart';
import 'features/gameplay/big_walker/game_room_scene.dart';
import 'features/gameplay/big_walker/animations/big_walker_motion.dart';
import 'features/gameplay/big_walker/widgets/big_walker_room_overlay_widgets.dart';
part 'features/catalog/catalog_container_part.dart';
part 'features/gameplay/room_screen_part.dart';
part 'features/home/home_container_part.dart';
part 'features/campaigns/campaigns_container_part.dart';
part 'features/profile/profile_container_part.dart';
part 'features/settings/settings_container_part.dart';

const String _apiBaseUrlFromEnv = String.fromEnvironment('API_BASE_URL', defaultValue: '');
const String _wsUrlFromEnv = String.fromEnvironment('WS_URL', defaultValue: '');
const String regionMode = String.fromEnvironment('REGION_MODE', defaultValue: 'global');
const String stunUrlsRaw = String.fromEnvironment('STUN_URLS', defaultValue: '');
const String turnUrlsRaw = String.fromEnvironment('TURN_URLS', defaultValue: '');
const String turnUsername = String.fromEnvironment('TURN_USERNAME', defaultValue: '');
const String turnCredential = String.fromEnvironment('TURN_CREDENTIAL', defaultValue: '');

String get apiBaseUrl {
  if (_apiBaseUrlFromEnv.isNotEmpty) return _apiBaseUrlFromEnv;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) return 'http://10.0.2.2:3000';
  return 'http://localhost:3000';
}

String get wsUrl {
  if (_wsUrlFromEnv.isNotEmpty) return _wsUrlFromEnv;
  if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) return 'ws://10.0.2.2:3001';
  return 'ws://localhost:3001';
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Для MVP фиксируем только landscape-ориентации, как указано в UX-требованиях.
  await SystemChrome.setPreferredOrientations(const [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  runApp(const TabletopApp());
}

class AppState extends ChangeNotifier {
  AppState({ApiClient? apiClient, WsClient? wsClient, AnalyticsClient? analyticsClient})
      : api = apiClient ?? ApiClient(apiBaseUrl),
        ws = wsClient ?? WsClient(wsUrl) {
    analytics = analyticsClient ?? AnalyticsClient(api);
  }

  final ApiClient api;
  final WsClient ws;
  late final AnalyticsClient analytics;

  String lang = 'ru';
  int tab = 0;
  bool authorized = true;
  bool authBusy = false;
  String? authError;
  String? userId = 'dev_autologin_user';
  List<dynamic> games = const [];
  List<dynamic> skus = const [];
  List<dynamic> inventoryItems = const [];
  List<dynamic> myVariants = const [];
  List<dynamic> campaigns = const [];
  List<dynamic> leaderboard = const [];
  String leaderboardPeriod = 'all-time';
  String purchaseStatus = '';
  String? appliedSkinSku;
  String? lastVariantLink;
  bool videoOverlayVisible = false;
  bool wsOffline = false;
  bool cameraEnabled = false;
  bool micEnabled = false;
  bool mediaPermissionGranted = false;
  String videoStatus = 'idle';
  final List<String> videoParticipants = [];
  Map<String, dynamic> analyticsDashboardData = const {};
  List<dynamic> analyticsEventsTable = const [];
  List<dynamic> moderationQueue = const [];
  List<dynamic> moderationAuditLog = const [];

  String? roomId;

  // Big Walker match state (источник истины остаётся в AppState).
  String currentGameId = 'big_walker_demo';
  String botLevel = 'easy';
  String matchMode = 'classic';
  bool nextLevelAvailable = false;
  int participantsCount = 2;
  List<int> walkerPositions = List.filled(6, 0);
  int currentPlayerIndex = 0;
  int diceValue = 1;
  bool isRollingDice = false;
  bool bigWalkerStarted = false;
  int turnNumber = 1;
  int? activePathIndex;
  int? winnerIndex;
  String bigWalkerOverlay = 'none';
  bool turnTransitionVisible = false;
  int? transitionPlayerIndex;
  int? settlingPlayerIndex;
  int pawnSettleTick = 0;
  bool unityBigWalkerRunning = false;

  List<List<String?>> tileGrid = List.generate(4, (_) => List.filled(4, null));
  String selectedTile = 'A';
  int? previewRow;
  int? previewCol;

  List<int> dice = [3, 2];
  List<List<int>> rollSheet = List.generate(5, (_) => List.filled(5, 0));

  final List<String> roomLog = [];
  final List<String> chat = [];
  bool yourTurn = true;

  Color get activeBoardHighlight => appliedSkinSku == 'skin.dice.neon' ? AppTokens.ok : AppTokens.boardHighlight;


  BigWalkerMatchViewState get bigWalkerViewState => BigWalkerMatchViewState(
    title: 'Большая бродилка',
    participantsCount: participantsCount,
    walkerPositions: List<int>.from(walkerPositions),
    currentPlayerIndex: currentPlayerIndex,
    diceValue: diceValue,
    isRollingDice: isRollingDice,
    turnNumber: turnNumber,
    activePathIndex: activePathIndex,
    winnerIndex: winnerIndex,
    isStarted: bigWalkerStarted,
    overlay: bigWalkerOverlay,
    turnTransitionVisible: turnTransitionVisible,
    transitionPlayerIndex: transitionPlayerIndex,
    settlingPlayerIndex: settlingPlayerIndex,
    pawnSettleTick: pawnSettleTick,
  );

  BigWalkerMatchActions get bigWalkerActions => BigWalkerMatchActions(
    onParticipantsCountChanged: setParticipantsCount,
    onRollDice: () {
      rollDiceAndMoveWalker();
    },
    onToggleVideo: toggleVideoOverlay,
    onToggleMic: toggleMic,
    onQuickChat: () {
      sendChat('Привет!');
    },
    onStartMatch: startBigWalkerMatch,
    onOpenPause: () => setBigWalkerOverlay('pause'),
    onOpenRules: () => setBigWalkerOverlay('rules'),
    onOpenSettings: () => setBigWalkerOverlay('settings'),
    onCloseOverlay: closeBigWalkerOverlay,
  );


  BigWalkerViewModel get bigWalkerViewModel => BigWalkerViewModel(
    state: bigWalkerViewState,
    actions: bigWalkerActions,
  );

  StreamSubscription<Map<String, dynamic>>? _wsSub;
  final Random _random = Random(7);

  String t(String key) => AppStrings.t(lang, key);
  String tr(String key, Map<String, String> values) => AppStrings.tr(lang, key, values);
  String tp(String key, int count) => AppStrings.tp(lang, key, count);
  String formatNumber(num value) => AppStrings.formatNumber(lang, value);
  String formatCurrency(num value) => AppStrings.formatCurrency(lang, value);

  Future<void> init() async {
    analytics.start();
    await ws.connect();
    _wsSub = ws.events.listen((event) {
      roomLog.add('WS: ${event['type'] ?? 'event'}');
      final eventType = event['type']?.toString() ?? '';
      if (eventType.startsWith('video.')) {
        videoStatus = 'signaling:${eventType.split('.').last}';
        analytics.enqueue(eventName: 'reconnect_count', userId: userId, payload: {'videoEvent': eventType});
      }
      if (eventType == 'offline') {
        wsOffline = true;
        analytics.incrementMetric('wsDisconnects');
        analytics.enqueue(eventName: 'ws_disconnects', userId: userId, payload: {'payload': event['payload']});
      } else if (eventType.isNotEmpty) {
        wsOffline = false;
      }
      notifyListeners();
    });
    games = await api.games();
    if (!games.any((item) => (item as Map<String, dynamic>)['id'] == 'big_walker_demo')) {
      games = [
        {
          'id': 'big_walker_demo',
          'title': 'Большая бродилка',
          'description': 'Путешествие по сказочным землям'
        },
        ...games
      ];
    }
    campaigns = await api.campaigns();
    final skuResponse = await api.storeSkus();
    skus = skuResponse['items'] as List<dynamic>? ?? const [];
    analytics.enqueue(eventName: 'store_view', payload: {'phase': 'init'});
    notifyListeners();
  }

  Future<void> loadCampaigns() async {
    campaigns = await api.campaigns();
    leaderboard = await api.leaderboard(period: leaderboardPeriod);
    notifyListeners();
  }

  Future<void> createCampaignQuick() async {
    final created = await api.createCampaign(
      name: 'Save the Plumpkin',
      description: 'Спасите Пухлю от злого волка!',
      levels: const [
        {'gameId': 'tile_placement_demo', 'campaignProgress': {'scoreMultiplier': 1.1}}
      ]
    );
    purchaseStatus = 'Campaign created: ${created['name']}';
    await loadCampaigns();
  }

  Future<void> startCampaignFlow(String campaignId) async {
    if (userId == null) return;
    final started = await api.startCampaign(campaignId: campaignId, players: [userId!, '${userId!}_bot']);
    roomId = (started['match'] as Map<String, dynamic>)['id']?.toString();
    tab = 4;
    notifyListeners();
  }

  Future<void> setLeaderboardPeriod(String value) async {
    leaderboardPeriod = value;
    leaderboard = await api.leaderboard(period: value);
    notifyListeners();
  }

  void setLang(String value) {
    lang = value;
    notifyListeners();
  }

  void setTab(int value) {
    tab = value;
    notifyListeners();
  }

  void setBotLevel(String level) {
    botLevel = level;
    notifyListeners();
  }

  void setCurrentGame(String gameId) {
    currentGameId = gameId;
    unityBigWalkerRunning = false;
    _resetBoards();
    notifyListeners();
  }

  void setParticipantsCount(int value) {
    participantsCount = value.clamp(BigWalkerTokens.minPlayers, BigWalkerTokens.maxPlayers);
    walkerPositions = List.generate(6, (index) => index < participantsCount ? 0 : -1);
    currentPlayerIndex = 0;
    winnerIndex = null;
    turnNumber = 1;
    bigWalkerStarted = false;
    activePathIndex = null;
    notifyListeners();
  }

  void setMatchMode(String mode) {
    matchMode = mode;
    notifyListeners();
  }

  Future<void> loginOrRegister(String email, String password, {required bool register}) async {
    authBusy = true;
    authError = null;
    notifyListeners();
    try {
      Map<String, dynamic> result;
      var flow = register ? 'register' : 'login';
      if (register) {
        try {
          result = await api.register(email, password);
        } catch (error) {
          final message = error.toString();
          if (message.contains('EMAIL_TAKEN')) {
            result = await api.login(email, password);
            flow = 'login_fallback_after_email_taken';
          } else {
            rethrow;
          }
        }
      } else {
        try {
          result = await api.login(email, password);
        } catch (error) {
          final message = error.toString();
          if (message.contains('INVALID_CREDENTIALS')) {
            result = await api.register(email, password);
            flow = 'register_fallback_after_invalid_credentials';
          } else {
            rethrow;
          }
        }
      }
      userId = (result['user']?['id'] ?? result['id'])?.toString();
      authorized = true;
      inventoryItems = await api.inventory(userId!);
      myVariants = await api.myVariants(userId!);
      analytics.enqueue(eventName: 'login_success', userId: userId, payload: {'register': register, 'flow': flow});
      await loadAdminAnalytics();
    } catch (error) {
      final message = error.toString();
      if (!register && message.contains('INVALID_CREDENTIALS')) {
        authError = 'Неверный логин/пароль. Если это первый вход, переключитесь на Register.';
      } else if (register && message.contains('EMAIL_TAKEN')) {
        authError = 'Email уже занят. Переключитесь на Login.';
      } else {
        authError = message;
      }
    } finally {
      authBusy = false;
      notifyListeners();
    }
  }

  Future<void> createPrivateRoom(String gameId) async {
    if (userId == null) return;
    currentGameId = gameId;
    _resetBoards();
    if (gameId == 'big_walker_demo') {
      roomId = 'room_big_walker_demo';
      nextLevelAvailable = false;
      unityBigWalkerRunning = false;
      setParticipantsCount(participantsCount);
      bigWalkerStarted = false;
      winnerIndex = null;
      videoParticipants
        ..clear()
        ..addAll(List.generate(participantsCount, (index) => index == 0 ? 'You' : 'Player ${index + 1}'));
      tab = 4;
      notifyListeners();
      return;
    }
    final result = await api.createMatch(gameId, [userId!, '${userId!}_bot'], mode: matchMode);
    roomId = result['id']?.toString();
    nextLevelAvailable = (result['legacyState'] as Map<String, dynamic>?)?['nextLevelAvailable'] == true;
    roomLog.add('Room created: $roomId, game: $gameId');
    videoParticipants
      ..clear()
      ..addAll([userId!, '${userId!}_bot']);
    videoOverlayVisible = false;
    cameraEnabled = false;
    micEnabled = false;
    mediaPermissionGranted = false;
    videoStatus = 'ready';
    analytics.enqueue(eventName: 'match_create', userId: userId, payload: {'gameId': gameId, 'roomId': roomId});
    tab = 4;
    notifyListeners();
  }

  void launchUnityBigWalker() {
    if (currentGameId != 'big_walker_demo') return;
    unityBigWalkerRunning = true;
    roomLog.add('Unity Big Walker runtime launched');
    notifyListeners();
  }

  void returnToHomeFromUnityBigWalker() {
    unityBigWalkerRunning = false;
    roomId = null;
    bigWalkerStarted = false;
    winnerIndex = null;
    tab = 0;
    notifyListeners();
  }

  Future<void> loadAdminAnalytics() async {
    try {
      analyticsEventsTable = await api.analyticsEvents(limit: 100);
      analyticsDashboardData = await api.analyticsDashboard();
      moderationQueue = await api.moderationCases();
      moderationAuditLog = await api.moderationAudit();
    } catch (_) {
      analyticsEventsTable = const [];
      analyticsDashboardData = const {};
      moderationQueue = const [];
      moderationAuditLog = const [];
    }
    notifyListeners();
  }

  Future<void> sendRoomReport({required String reason}) async {
    if (userId == null) return;
    // В MVP репорт отправляется из экрана комнаты в едином формате game_room.
    final response = await api.reportFromGameRoom(
      reporterUserId: userId!,
      targetType: 'chat',
      targetId: '${roomId ?? 'room_unknown'}:latest',
      reason: reason,
      policyType: 'no negotiation'
    );
    roomLog.add('Report sent: case=${response['case']?['id'] ?? '-'}');
    await loadAdminAnalytics();
    notifyListeners();
  }

  Future<void> refreshMyVariants() async {
    if (userId == null) return;
    myVariants = await api.myVariants(userId!);
    notifyListeners();
  }

  Future<Map<String, dynamic>> createVariantDraft({
    required String gameId,
    required int boardSize,
    required String winCondition,
    required double scoringMultiplier,
    int? turnTimer
  }) async {
    if (userId == null) return {};
    final draft = await api.createVariantDraft(
      userId: userId!,
      gameId: gameId,
      boardSize: boardSize,
      winCondition: winCondition,
      scoringMultipliers: {'base': scoringMultiplier},
      turnTimer: turnTimer
    );
    await refreshMyVariants();
    return draft;
  }

  Future<Map<String, dynamic>> validateVariant(String variantId) async {
    if (userId == null) return {'ok': false, 'errors': ['NOT_AUTHORIZED']};
    return api.validateVariant(variantId: variantId, userId: userId!);
  }

  Future<Map<String, dynamic>> publishVariant(String variantId) async {
    if (userId == null) return {'ok': false};
    final result = await api.publishVariant(variantId: variantId, userId: userId!);
    lastVariantLink = result['privateLink']?.toString();
    await refreshMyVariants();
    return result;
  }

  Future<void> startTestPlay(String variantId, String gameId) async {
    if (userId == null) return;
    final result = await api.createMatch(gameId, [userId!, '${userId!}_bot'], variantId: variantId, mode: matchMode);
    roomId = result['id']?.toString();
    currentGameId = gameId;
    tab = 4;
    notifyListeners();
  }

  Future<void> joinVariantByToken(String token) async {
    if (userId == null) return;
    final variant = await api.variantByPrivateLink(token);
    await createPrivateRoom(variant['gameId'].toString());
    final result = await api.createMatch(
      variant['gameId'].toString(),
      [userId!, '${userId!}_bot'],
      variantId: variant['id'].toString(),
      mode: matchMode
    );
    roomId = result['id']?.toString();
    currentGameId = variant['gameId'].toString();
    tab = 4;
    notifyListeners();
  }

  void updatePreview(int? row, int? col) {
    previewRow = row;
    previewCol = col;
    notifyListeners();
  }

  void confirmTilePlacement(int row, int col) {
    if (!yourTurn || currentGameId != 'tile_placement_demo') return;
    if (tileGrid[row][col] != null) return;
    tileGrid[row][col] = selectedTile;
    roomLog.add('Tile placed: [$row,$col] = $selectedTile');
    analytics.enqueue(eventName: 'match_move', userId: userId, payload: {'gameId': currentGameId, 'row': row, 'col': col});
    yourTurn = false;
    _botTurn();
    notifyListeners();
  }

  void toggleTileSymbol() {
    selectedTile = selectedTile == 'A' ? 'B' : 'A';
    notifyListeners();
  }

  void markRollCell(int row, int col) {
    if (!yourTurn || currentGameId != 'roll_and_write_demo') return;
    if (rollSheet[row][col] == 1) return;
    final expected = dice[0] + dice[1];
    if (row + col + 2 != expected) {
      roomLog.add('Illegal move: dice rule violation');
      notifyListeners();
      return;
    }
    rollSheet[row][col] = 1;
    roomLog.add('Sheet marked: [$row,$col], dice=$expected');
    analytics.enqueue(eventName: 'match_move', userId: userId, payload: {'gameId': currentGameId, 'row': row, 'col': col});
    yourTurn = false;
    _botTurn();
    notifyListeners();
  }

  void _botTurn() {
    if (botLevel == 'easy') {
      _applyRandomBotMove();
    } else {
      _applyHeuristicBotMove();
    }
    yourTurn = true;
  }

  void _applyRandomBotMove() {
    if (currentGameId == 'tile_placement_demo') {
      for (int r = 0; r < 4; r += 1) {
        for (int c = 0; c < 4; c += 1) {
          if (tileGrid[r][c] == null) {
            tileGrid[r][c] = 'B';
            roomLog.add('Bot($botLevel) placed at [$r,$c]');
            return;
          }
        }
      }
      return;
    }

    final expected = dice[0] + dice[1];
    for (int r = 0; r < 5; r += 1) {
      for (int c = 0; c < 5; c += 1) {
        if (rollSheet[r][c] == 0 && r + c + 2 == expected) {
          rollSheet[r][c] = 1;
          _rerollDice();
          roomLog.add('Bot($botLevel) marked [$r,$c]');
          return;
        }
      }
    }
  }

  void _applyHeuristicBotMove() {
    if (currentGameId == 'tile_placement_demo') {
      int? bestR;
      int? bestC;
      int bestScore = -1;
      for (int r = 0; r < 4; r += 1) {
        for (int c = 0; c < 4; c += 1) {
          if (tileGrid[r][c] != null) continue;
          final score = _tilePotentialScore(r, c, 'B');
          if (score > bestScore) {
            bestScore = score;
            bestR = r;
            bestC = c;
          }
        }
      }
      if (bestR != null && bestC != null) {
        tileGrid[bestR][bestC] = 'B';
        roomLog.add('Bot(normal) placed at [$bestR,$bestC], score=$bestScore');
      }
      return;
    }

    final expected = dice[0] + dice[1];
    int? bestR;
    int? bestC;
    int bestCenterScore = -1;
    for (int r = 0; r < 5; r += 1) {
      for (int c = 0; c < 5; c += 1) {
        if (rollSheet[r][c] != 0 || r + c + 2 != expected) continue;
        final centerScore = 10 - ((r - 2).abs() + (c - 2).abs());
        if (centerScore > bestCenterScore) {
          bestCenterScore = centerScore;
          bestR = r;
          bestC = c;
        }
      }
    }
    if (bestR != null && bestC != null) {
      rollSheet[bestR][bestC] = 1;
      _rerollDice();
      roomLog.add('Bot(normal) marked [$bestR,$bestC], h=$bestCenterScore');
    }
  }

  int _tilePotentialScore(int row, int col, String symbol) {
    int score = 1;
    const dirs = [
      [1, 0],
      [-1, 0],
      [0, 1],
      [0, -1]
    ];
    for (final d in dirs) {
      final nr = row + d[0];
      final nc = col + d[1];
      if (nr >= 0 && nr < 4 && nc >= 0 && nc < 4 && tileGrid[nr][nc] == symbol) score += 1;
    }
    return score;
  }

  void _rerollDice() {
    dice = [1 + _random.nextInt(6), 1 + _random.nextInt(6)];
  }

  void sendChat(String text) {
    if (text.trim().isEmpty) return;
    chat.add(text);
    ws.send({'type': 'chat.message', 'text': text, 'roomId': roomId});
    notifyListeners();
  }

  bool get isRtcConfigured => stunUrlsRaw.trim().isNotEmpty || turnUrlsRaw.trim().isNotEmpty;

  String get rtcConfigWarning {
    if (isRtcConfigured) return '';
    return 'STUN/TURN не настроены: укажите STUN_URLS или TURN_URLS, TURN_USERNAME, TURN_CREDENTIAL.';
  }

  void grantMediaPermission() {
    mediaPermissionGranted = true;
    notifyListeners();
  }

  void toggleVideoOverlay() {
    videoOverlayVisible = !videoOverlayVisible;
    notifyListeners();
  }

  void toggleCamera() {
    if (!mediaPermissionGranted) return;
    cameraEnabled = !cameraEnabled;
    if (roomId != null && userId != null && videoParticipants.length > 1) {
      ws.sendVideoOffer(
        roomId: roomId!,
        fromUserId: userId!,
        targetUserId: videoParticipants.last,
        sdp: cameraEnabled ? 'offer-camera-on' : 'offer-camera-off'
      );
    }
    videoStatus = cameraEnabled ? 'camera_on' : 'camera_off';
    if (!isRtcConfigured) {
      analytics.incrementMetric('videoConnectFailures');
      analytics.enqueue(eventName: 'video_connect_failures', userId: userId, payload: {'reason': 'rtc_not_configured'});
    }
    notifyListeners();
  }

  void toggleMic() {
    if (!mediaPermissionGranted) return;
    micEnabled = !micEnabled;
    videoStatus = micEnabled ? 'mic_on' : 'mic_off';
    notifyListeners();
  }

  void hangupVideo() {
    cameraEnabled = false;
    micEnabled = false;
    videoOverlayVisible = false;
    videoStatus = 'hangup';
    notifyListeners();
  }

  void muteAllVideo() {
    micEnabled = false;
    cameraEnabled = false;
    videoStatus = 'muted_all';
    notifyListeners();
  }

  Future<void> sandboxPurchase() async {
    if (userId == null) return;
    final first = skus.isNotEmpty ? (skus.first as Map<String, dynamic>)['sku']?.toString() : 'skin.dice.neon';
    await api.purchaseSandbox(userId!, first ?? 'skin.dice.neon');
    inventoryItems = await api.inventory(userId!);
    roomLog.add('Sandbox purchase completed');
    notifyListeners();
  }

  Future<void> buySku(String sku) async {
    if (userId == null) return;
    if (regionMode == 'ru_by') {
      purchaseStatus = 'Недоступно в регионе ru_by';
      notifyListeners();
      return;
    }

    final iap = InAppPurchase.instance;
    final productResponse = await iap.queryProductDetails({sku});
    if (productResponse.productDetails.isNotEmpty) {
      final purchaseParam = PurchaseParam(productDetails: productResponse.productDetails.first);
      await iap.buyNonConsumable(purchaseParam: purchaseParam);
      await api.purchaseIapSuccess(userId: userId!, sku: sku, platform: defaultTargetPlatform.name, purchaseToken: 'local_receipt');
      purchaseStatus = 'IAP purchase requested: $sku';
    } else {
      await api.purchaseSandbox(userId!, sku);
      purchaseStatus = 'Sandbox fallback purchase: $sku';
    }
    inventoryItems = await api.inventory(userId!);
    notifyListeners();
  }

  Future<void> restorePurchases() async {
    if (regionMode == 'ru_by') {
      purchaseStatus = 'Недоступно в регионе ru_by';
      notifyListeners();
      return;
    }
    await InAppPurchase.instance.restorePurchases();
    purchaseStatus = 'Restore purchases requested';
    notifyListeners();
  }



  void startBigWalkerMatch() {
    walkerPositions = List.generate(6, (index) => index < participantsCount ? 0 : -1);
    currentPlayerIndex = 0;
    diceValue = 1;
    turnNumber = 1;
    winnerIndex = null;
    activePathIndex = 0;
    bigWalkerStarted = true;
    isRollingDice = false;
    bigWalkerOverlay = 'none';
    turnTransitionVisible = false;
    transitionPlayerIndex = null;
    notifyListeners();
  }

  void setBigWalkerOverlay(String value) {
    bigWalkerOverlay = value;
    notifyListeners();
  }

  void closeBigWalkerOverlay() {
    bigWalkerOverlay = 'none';
    notifyListeners();
  }

  Future<void> nextLegacyLevel() async {
    if (roomId == null) return;
    final result = await api.nextLevel(roomId!);
    roomId = result['id']?.toString();
    nextLevelAvailable = false;
    tab = 4;
    notifyListeners();
  }

  // Big Walker mechanics (без изменения правил).
  Future<void> rollDiceAndMoveWalker() async {
    if (!bigWalkerStarted || isRollingDice || winnerIndex != null) return;
    final rollPhaseWatch = Stopwatch()..start();
    isRollingDice = true;
    notifyListeners();

    for (int i = 0; i < BigWalkerTokens.diceRollFrames; i += 1) {
      diceValue = BigWalkerTokens.diceMin + _random.nextInt(BigWalkerTokens.diceMax);
      notifyListeners();
      await Future<void>.delayed(BigWalkerMotion.dicePulse);
    }
    final remainingRollPhase = BigWalkerMotion.diceRollMinVisible - rollPhaseWatch.elapsed;
    if (!remainingRollPhase.isNegative) {
      await Future<void>.delayed(remainingRollPhase);
    }

    final rolled = diceValue;
    final startPos = walkerPositions[currentPlayerIndex].clamp(0, BigWalkerTokens.totalCells - 1);
    final finalPos = (startPos + rolled).clamp(0, BigWalkerTokens.totalCells - 1);
    final stepDirection = finalPos >= startPos ? 1 : -1;
    final steps = (finalPos - startPos).abs();
    for (int step = 1; step <= steps; step += 1) {
      final nextPos = startPos + (step * stepDirection);
      walkerPositions[currentPlayerIndex] = nextPos;
      activePathIndex = nextPos;
      notifyListeners();
      await Future<void>.delayed(BigWalkerMotion.cellStep);
    }

    settlingPlayerIndex = currentPlayerIndex;
    pawnSettleTick += 1;
    notifyListeners();
    await Future<void>.delayed(BigWalkerMotion.pawnSettle);
    settlingPlayerIndex = null;
    notifyListeners();

    roomLog.add('Player ${currentPlayerIndex + 1} бросил $rolled и перешел на ${finalPos + 1}');

    if (finalPos >= BigWalkerTokens.totalCells - 1) {
      winnerIndex = currentPlayerIndex;
      isRollingDice = false;
      notifyListeners();
      return;
    }

    currentPlayerIndex = (currentPlayerIndex + 1) % participantsCount;
    transitionPlayerIndex = currentPlayerIndex;
    turnTransitionVisible = true;
    turnNumber += 1;
    isRollingDice = false;
    notifyListeners();
    await Future<void>.delayed(BigWalkerMotion.overlayVisible);
    turnTransitionVisible = false;
    notifyListeners();
  }

  void trySkin(String sku) {
    appliedSkinSku = sku;
    notifyListeners();
  }

  Future<void> applySkin(String sku) async {
    if (userId == null) return;
    await api.applySkin(userId!, sku);
    appliedSkinSku = sku;
    inventoryItems = await api.inventory(userId!);
    notifyListeners();
  }

  void _resetBoards() {
    tileGrid = List.generate(4, (_) => List.filled(4, null));
    rollSheet = List.generate(5, (_) => List.filled(5, 0));
    dice = [3, 2];
    walkerPositions = List.generate(6, (index) => index < participantsCount ? 0 : -1);
    currentPlayerIndex = 0;
    diceValue = 1;
    isRollingDice = false;
    bigWalkerStarted = false;
    turnNumber = 1;
    activePathIndex = null;
    winnerIndex = null;
    bigWalkerOverlay = 'none';
    turnTransitionVisible = false;
    transitionPlayerIndex = null;
    settlingPlayerIndex = null;
    pawnSettleTick = 0;
    yourTurn = true;
    previewRow = null;
    previewCol = null;
  }

  @override
  void dispose() {
    analytics.stop();
    unawaited(analytics.flush());
    _wsSub?.cancel();
    ws.disconnect();
    super.dispose();
  }
}

class TabletopApp extends StatefulWidget {
  const TabletopApp({super.key});
  @override
  State<TabletopApp> createState() => _TabletopAppState();
}

class _TabletopAppState extends State<TabletopApp> {
  final AppState state = AppState();

  @override
  void initState() {
    super.initState();
    state.init();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: state,
      builder: (context, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'TabletopPlatform',
        theme: AppTheme.build(),
        // Временный bypass auth для эмулятора: сразу открываем основной shell.
        home: MainShell(state: state)
      )
    );
  }
}

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key, required this.state});
  final AppState state;
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final email = TextEditingController(text: 'demo@local.dev');
  final password = TextEditingController(text: 'secret01');
  bool register = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(AppTokens.s16, AppTokens.s16, AppTokens.s16, MediaQuery.of(context).viewInsets.bottom + AppTokens.s16),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppTokens.s16),
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text(register ? widget.state.t('auth.register') : widget.state.t('auth.login')),
                    AppTextInput(controller: email, label: widget.state.t('auth.email')),
                    AppTextInput(controller: password, label: widget.state.t('auth.password')),
                    const SizedBox(height: AppTokens.s12),
                    AppPrimaryButton(
                      onPressed: widget.state.authBusy
                          ? null
                          : () => widget.state.loginOrRegister(email.text.trim(), password.text.trim(), register: register),
                      label: widget.state.authBusy ? '...' : (register ? widget.state.t('auth.register') : widget.state.t('auth.login'))
                    ),
                    if (widget.state.authError != null)
                      Padding(
                        padding: const EdgeInsets.only(top: AppTokens.s8),
                        child: Text(widget.state.authError!, style: const TextStyle(color: AppTokens.editorWarning))
                      ),
                    AppGhostButton(onPressed: () => setState(() => register = !register), label: register ? 'Login' : 'Register')
                  ])
                )
              )
            )
          )
        )
      )
    );
  }
}

class MainShell extends StatelessWidget {
  const MainShell({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final pages = [
      HomeScreen(state: state),
      CatalogScreen(state: state),
      CampaignsScreen(state: state),
      CreateScreen(state: state),
      RoomScreen(state: state),
      StoreScreen(state: state),
      ProfileScreen(state: state),
      SettingsScreen(state: state)
    ];
    final breadcrumbItems = [
      state.t('tab.home'),
      state.t('tab.catalog'),
      'Campaigns',
      state.t('tab.create'),
      state.t('tab.room'),
      state.t('tab.store'),
      state.t('tab.profile'),
      state.t('tab.settings')
    ];
    return Scaffold(
      body: Column(
        children: [
          ReconnectBanner(visible: state.wsOffline, text: 'Проблемы с соединением. Пытаемся переподключиться...'),
          if (state.tab != 4)
            Padding(
              padding: AppLayout.safeAwarePadding(context, horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              child: BreadcrumbNav(items: breadcrumbItems, currentIndex: state.tab, onTap: state.setTab),
            ),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
              child: KeyedSubtree(key: ValueKey(state.tab), child: pages[state.tab])
            )
          )
        ]
      ),
    );
  }
}


class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key, required this.state});
  final AppState state;
  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final boardSize = TextEditingController(text: '4');
  final winCondition = TextEditingController(text: 'highest_score');
  final scoring = TextEditingController(text: '1.0');
  final turnTimer = TextEditingController(text: '30');
  final joinToken = TextEditingController();
  String selectedGameId = 'tile_placement_demo';
  String message = '';

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    return ListView(
      padding: const EdgeInsets.all(AppTokens.s16),
      children: [
        Text(s.t('editor.title'), style: const TextStyle(fontSize: AppTokens.editorSectionTitle, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Text(s.t('editor.myVariants')),
        ...s.myVariants.map((raw) {
          final v = raw as Map<String, dynamic>;
          final hasErrors = (v['validationErrors'] as List<dynamic>? ?? const []).isNotEmpty;
          return Card(
            child: ListTile(
              title: Text('${v['gameId']} • ${v['status']}'),
              subtitle: Text(
                s.tr('editor.variantMeta', {
                  'board': '${v['boardSize']}',
                  'win': '${v['winCondition']}'
                })
              ),
              trailing: Wrap(spacing: 8, children: [
                OutlinedButton(
                  onPressed: () async {
                    final result = await s.validateVariant(v['id'].toString());
                    setState(() => message = 'validate: ${result['ok']} / ${result['errors'] ?? const []}');
                  },
                  child: Text(s.t('editor.validate'))
                ),
                FilledButton(
                  onPressed: () async {
                    await s.startTestPlay(v['id'].toString(), v['gameId'].toString());
                  },
                  child: Text(s.t('editor.test'))
                ),
                TextButton(
                  onPressed: hasErrors
                      ? null
                      : () async {
                          final result = await s.publishVariant(v['id'].toString());
                          setState(() => message = '${s.t('editor.linkReady')}: ${result['privateLink'] ?? '-'}');
                        },
                  child: Text(s.t('editor.publish'))
                )
              ])
            )
          );
        }),
        const SizedBox(height: 8),
        TextField(controller: boardSize, decoration: InputDecoration(labelText: s.t('editor.boardSize'))),
        TextField(controller: winCondition, decoration: InputDecoration(labelText: s.t('editor.winCondition'))),
        TextField(controller: scoring, decoration: InputDecoration(labelText: s.t('editor.scoring'))),
        TextField(controller: turnTimer, decoration: InputDecoration(labelText: s.t('editor.turnTimer'))),
        DropdownButtonFormField<String>(
          value: selectedGameId,
          items: const [
            DropdownMenuItem(value: 'tile_placement_demo', child: Text('tile_placement_demo')),
            DropdownMenuItem(value: 'roll_and_write_demo', child: Text('roll_and_write_demo'))
          ],
          onChanged: (value) => setState(() => selectedGameId = value ?? 'tile_placement_demo')
        ),
        const SizedBox(height: 8),
        Row(children: [
          FilledButton(
            onPressed: () async {
              final created = await s.createVariantDraft(
                gameId: selectedGameId,
                boardSize: int.tryParse(boardSize.text) ?? 4,
                winCondition: winCondition.text.trim(),
                scoringMultiplier: double.tryParse(scoring.text) ?? 1,
                turnTimer: int.tryParse(turnTimer.text)
              );
              setState(() => message = 'draft: ${created['id'] ?? '-'}');
            },
            child: Text(s.t('editor.createDraft'))
          )
        ]),
        const SizedBox(height: 8),
        TextField(controller: joinToken, decoration: InputDecoration(labelText: s.t('editor.joinVariant'))),
        OutlinedButton(
          onPressed: () async {
            await s.joinVariantByToken(joinToken.text.trim());
          },
          child: Text(s.t('editor.joinVariant'))
        ),
        if (message.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(message, style: const TextStyle(color: AppTokens.editorWarning))
          )
      ]
    );
  }
}

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Column(children: [
        const TabBar(tabs: [Tab(text: 'Games'), Tab(text: 'Skins'), Tab(text: 'Subscriptions'), Tab(text: 'Inventory')]),
        Expanded(
          child: PageTransitionSwitcher(
            duration: AppMotion.medium,
            transitionBuilder: (child, primary, secondary) => FadeThroughTransition(
              animation: primary,
              secondaryAnimation: secondary,
              child: child,
            ),
            child: TabBarView(children: [
              ListView(
                children: state.skus
                    .where((e) => (e as Map<String, dynamic>)['type'] == 'GAME_LICENSE')
                    .map((e) => _StoreSkuTile(state: state, sku: e as Map<String, dynamic>))
                    .toList()
              ),
              ListView(
                children: state.skus
                    .where((e) => (e as Map<String, dynamic>)['type'] == 'COSMETIC')
                    .map((e) => _StoreSkinTile(state: state, sku: e as Map<String, dynamic>))
                    .toList()
              ),
              ListView(
                children: [
                  ListTile(
                    title: const Text('Season Pass'),
                    subtitle: Text('Price: \$4.99', style: AppTypography.h3.copyWith(color: AppColors.storePriceAccent)),
                    trailing: Wrap(
                      spacing: AppSpacing.xs,
                      children: [
                        FilledButton(onPressed: () => state.buySku('season.pass'), child: const Text('Subscribe Now')),
                        OutlinedButton(onPressed: state.restorePurchases, child: const Text('Restore Purchase')),
                      ],
                    ),
                  ),
                  if (state.purchaseStatus.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.all(AppSpacing.sm),
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      decoration: BoxDecoration(color: AppColors.storeAlertBg, borderRadius: BorderRadius.circular(AppTokens.uiButtonRadius)),
                      child: Text(state.purchaseStatus),
                    )
                ],
              ),
              ListView(
                children: state.inventoryItems
                    .map((e) => _InventoryTile(state: state, item: e as Map<String, dynamic>))
                    .toList()
              )
            ]),
          )
        )
      ])
    );
  }
}

class _StoreSkuTile extends StatelessWidget {
  const _StoreSkuTile({required this.state, required this.sku});
  final AppState state;
  final Map<String, dynamic> sku;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(sku['title'].toString()),
      subtitle: Text(sku['sku'].toString()),
      trailing: FilledButton(onPressed: () => state.buySku(sku['sku'].toString()), child: Text(state.t('store.buy')))
    );
  }
}

class _StoreSkinTile extends StatelessWidget {
  const _StoreSkinTile({required this.state, required this.sku});
  final AppState state;
  final Map<String, dynamic> sku;

  @override
  Widget build(BuildContext context) {
    final color = AppTokens.priceTag;
    return Card(
      child: ListTile(
        title: Text(sku['title'].toString()),
        subtitle: Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            color: color,
            child: Text(state.formatCurrency((sku['priceSandbox'] as num?) ?? 0))
          ),
          const SizedBox(width: 8),
          if (sku['isNew'] == true) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), color: AppTokens.storeBadgeNew, child: Text(state.t('store.new')))
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          OutlinedButton(onPressed: () => state.trySkin(sku['sku'].toString()), child: Text(state.t('store.try'))),
          const SizedBox(width: 8),
          FilledButton(onPressed: () => state.buySku(sku['sku'].toString()), child: Text(state.t('store.buy'))),
          const SizedBox(width: 8),
          TextButton(onPressed: () => state.applySkin(sku['sku'].toString()), child: Text(state.t('store.apply')))
        ])
      )
    );
  }
}

class _InventoryTile extends StatelessWidget {
  const _InventoryTile({required this.state, required this.item});
  final AppState state;
  final Map<String, dynamic> item;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(item['sku'].toString()),
      subtitle: Text(item['type'].toString()),
      trailing: item['type'] == 'COSMETIC'
          ? FilledButton(onPressed: () => state.applySkin(item['sku'].toString()), child: Text(state.t('store.apply')))
          : const SizedBox.shrink()
    );
  }
}
