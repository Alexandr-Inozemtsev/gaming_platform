// Назначение файла: собрать мобильный MVP-клиент с экранами, состоянием, API/WebSocket и игровыми досками двух демо-игр.
// Роль в проекте: быть основной точкой входа Flutter-приложения и связывать UX-сценарии auth/home/catalog/room/store/settings.
// Основные функции: управление AppState, i18n RU/EN, room flow, board widgets для tile/roll-write, локальные боты easy/normal.
// Связи с другими файлами: использует i18n/strings.dart, services/api_client.dart, services/ws_client.dart и theme/tokens.dart.
// Важно при изменении: держать сетевую логику в AppState/сервисах и не переносить сервер-правила напрямую в UI без синхронизации с backend.

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import 'i18n/strings.dart';
import 'services/api_client.dart';
import 'services/ws_client.dart';
import 'theme/tokens.dart';

const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');
const String wsUrl = String.fromEnvironment('WS_URL', defaultValue: 'ws://localhost:3001');
const String stunUrlsRaw = String.fromEnvironment('STUN_URLS', defaultValue: '');
const String turnUrlsRaw = String.fromEnvironment('TURN_URLS', defaultValue: '');
const String turnUsername = String.fromEnvironment('TURN_USERNAME', defaultValue: '');
const String turnCredential = String.fromEnvironment('TURN_CREDENTIAL', defaultValue: '');

void main() => runApp(const TabletopApp());

class AppState extends ChangeNotifier {
  AppState()
      : api = ApiClient(apiBaseUrl),
        ws = WsClient(wsUrl);

  final ApiClient api;
  final WsClient ws;

  String lang = 'ru';
  int tab = 0;
  bool authorized = false;
  String? userId;
  List<dynamic> games = const [];
  List<dynamic> skus = const [];
  List<dynamic> inventoryItems = const [];
  List<dynamic> myVariants = const [];
  String? appliedSkinSku;
  String? lastVariantLink;
  bool videoOverlayVisible = false;
  bool cameraEnabled = false;
  bool micEnabled = false;
  bool mediaPermissionGranted = false;
  String videoStatus = 'idle';
  final List<String> videoParticipants = [];

  String? roomId;
  String currentGameId = 'tile_placement_demo';
  String botLevel = 'easy';

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

  StreamSubscription<Map<String, dynamic>>? _wsSub;
  final Random _random = Random(7);

  String t(String key) => AppStrings.t(lang, key);

  Future<void> init() async {
    await ws.connect();
    _wsSub = ws.events.listen((event) {
      roomLog.add('WS: ${event['type'] ?? 'event'}');
      final eventType = event['type']?.toString() ?? '';
      if (eventType.startsWith('video.')) {
        videoStatus = 'signaling:${eventType.split('.').last}';
      }
      notifyListeners();
    });
    games = await api.games();
    final skuResponse = await api.storeSkus();
    skus = skuResponse['items'] as List<dynamic>? ?? const [];
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
    _resetBoards();
    notifyListeners();
  }

  Future<void> loginOrRegister(String email, String password, {required bool register}) async {
    final result = register ? await api.register(email, password) : await api.login(email, password);
    userId = (result['user']?['id'] ?? result['id'])?.toString();
    authorized = true;
    inventoryItems = await api.inventory(userId!);
    myVariants = await api.myVariants(userId!);
    notifyListeners();
  }

  Future<void> createPrivateRoom(String gameId) async {
    if (userId == null) return;
    currentGameId = gameId;
    _resetBoards();
    final result = await api.createMatch(gameId, [userId!, '${userId!}_bot']);
    roomId = result['id']?.toString();
    roomLog.add('Room created: $roomId, game: $gameId');
    videoParticipants
      ..clear()
      ..addAll([userId!, '${userId!}_bot']);
    videoOverlayVisible = false;
    cameraEnabled = false;
    micEnabled = false;
    mediaPermissionGranted = false;
    videoStatus = 'ready';
    tab = 3;
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
    final result = await api.createMatch(gameId, [userId!, '${userId!}_bot'], variantId: variantId);
    roomId = result['id']?.toString();
    currentGameId = gameId;
    tab = 3;
    notifyListeners();
  }

  Future<void> joinVariantByToken(String token) async {
    if (userId == null) return;
    final variant = await api.variantByPrivateLink(token);
    await createPrivateRoom(variant['gameId'].toString());
    final result = await api.createMatch(
      variant['gameId'].toString(),
      [userId!, '${userId!}_bot'],
      variantId: variant['id'].toString()
    );
    roomId = result['id']?.toString();
    currentGameId = variant['gameId'].toString();
    tab = 3;
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
    await api.purchaseSandbox(userId!, sku);
    inventoryItems = await api.inventory(userId!);
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
    yourTurn = true;
    previewRow = null;
    previewCol = null;
  }

  @override
  void dispose() {
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
        home: state.authorized ? MainShell(state: state) : AuthScreen(state: state)
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.s16),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(register ? widget.state.t('auth.register') : widget.state.t('auth.login')),
                TextField(controller: email, decoration: InputDecoration(labelText: widget.state.t('auth.email'))),
                TextField(controller: password, decoration: InputDecoration(labelText: widget.state.t('auth.password'))),
                const SizedBox(height: AppTokens.s12),
                FilledButton(
                  onPressed: () => widget.state.loginOrRegister(email.text.trim(), password.text.trim(), register: register),
                  child: Text(register ? widget.state.t('auth.register') : widget.state.t('auth.login'))
                ),
                TextButton(onPressed: () => setState(() => register = !register), child: Text(register ? 'Login' : 'Register'))
              ])
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
      CreateScreen(state: state),
      RoomScreen(state: state),
      StoreScreen(state: state),
      ProfileScreen(state: state),
      SettingsScreen(state: state)
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('TabletopPlatform')),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 280),
        transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
        child: KeyedSubtree(key: ValueKey(state.tab), child: pages[state.tab])
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: state.tab,
        onDestinationSelected: state.setTab,
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home), label: state.t('tab.home')),
          NavigationDestination(icon: const Icon(Icons.grid_view), label: state.t('tab.catalog')),
          NavigationDestination(icon: const Icon(Icons.edit_note), label: state.t('tab.create')),
          NavigationDestination(icon: const Icon(Icons.meeting_room), label: state.t('tab.room')),
          NavigationDestination(icon: const Icon(Icons.store), label: state.t('tab.store')),
          NavigationDestination(icon: const Icon(Icons.person), label: state.t('tab.profile')),
          NavigationDestination(icon: const Icon(Icons.settings), label: state.t('tab.settings'))
        ]
      )
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTokens.s16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.s16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(state.t('home.continue')),
            const SizedBox(height: AppTokens.s12),
            Row(children: [
              FilledButton(onPressed: () => state.setTab(3), child: Text(state.t('home.play'))),
              const SizedBox(width: AppTokens.s12),
              OutlinedButton(onPressed: () => state.createPrivateRoom(state.currentGameId), child: Text(state.t('home.createRoom')))
            ]),
            const SizedBox(height: AppTokens.s12),
            Text(state.t('home.teaser'))
          ])
        )
      )
    );
  }
}

class CatalogScreen extends StatelessWidget {
  const CatalogScreen({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTokens.s16),
      children: [
        Wrap(spacing: 8, children: [
          ChoiceChip(label: const Text('easy'), selected: state.botLevel == 'easy', onSelected: (_) => state.setBotLevel('easy')),
          ChoiceChip(label: const Text('normal'), selected: state.botLevel == 'normal', onSelected: (_) => state.setBotLevel('normal'))
        ]),
        const SizedBox(height: 8),
        ...state.games.map((raw) {
          final game = raw as Map<String, dynamic>;
          return Card(
            child: ListTile(
              title: Text(game['title']?.toString() ?? game['id'].toString()),
              subtitle: Text(game['id'].toString()),
              trailing: FilledButton(
                onPressed: () {
                  state.setCurrentGame(game['id'].toString());
                  state.createPrivateRoom(game['id'].toString());
                },
                child: const Text('Join')
              )
            )
          );
        })
      ]
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
              subtitle: Text('board=${v['boardSize']}, win=${v['winCondition']}'),
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

class RoomScreen extends StatefulWidget {
  const RoomScreen({super.key, required this.state});
  final AppState state;
  @override
  State<RoomScreen> createState() => _RoomScreenState();
}

class _RoomScreenState extends State<RoomScreen> with SingleTickerProviderStateMixin {
  late final AnimationController pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..repeat(reverse: true);
  final chat = TextEditingController();

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.state;
    return Stack(children: [
      Padding(
        padding: const EdgeInsets.all(AppTokens.s16),
        child: Column(children: [
          Expanded(
            flex: 2,
            child: Card(
              child: Column(children: [
                const SizedBox(height: 8),
                Text(s.currentGameId),
                Expanded(child: s.currentGameId == 'tile_placement_demo' ? TileBoardWidget(state: s) : RollWriteBoardWidget(state: s))
              ])
            )
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Row(children: [
              Expanded(child: Card(child: ListView(padding: const EdgeInsets.all(8), children: s.roomLog.map((e) => Text('• $e')).toList()))),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  child: Column(children: [
                    Expanded(child: ListView(padding: const EdgeInsets.all(8), children: s.chat.map((e) => Text('💬 $e')).toList())),
                    Row(children: [
                      Expanded(child: TextField(controller: chat)),
                      IconButton(onPressed: () { s.sendChat(chat.text); chat.clear(); }, icon: const Icon(Icons.send))
                    ])
                  ])
                )
              )
            ])
          ),
          const SizedBox(height: 8),
          AnimatedBuilder(
            animation: pulse,
            builder: (_, __) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: s.activeBoardHighlight.withOpacity(s.yourTurn ? 0.4 + pulse.value * 0.4 : 0.2),
                borderRadius: BorderRadius.circular(AppTokens.radiusButton)
              ),
              child: Text(s.t('room.yourTurn'))
            )
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FilledButton.icon(
              onPressed: s.toggleVideoOverlay,
              icon: const Icon(Icons.videocam),
              label: Text(s.t('video.openOverlay'))
            )
          )
        ])
      ),
      if (s.videoOverlayVisible) VideoOverlayWidget(state: s)
    ]);
  }
}

class VideoOverlayWidget extends StatelessWidget {
  const VideoOverlayWidget({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    final warning = state.rtcConfigWarning;
    return Positioned.fill(
      child: Container(
        color: AppTokens.videoOverlayBg,
        padding: const EdgeInsets.all(12),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                Text(state.t('video.title')),
                if (warning.isNotEmpty)
                  Text(
                    warning,
                    style: const TextStyle(color: AppTokens.editorWarning)
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: state.videoParticipants.take(4).map((id) {
                    return Container(
                      width: 120,
                      height: 80,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTokens.card.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(AppTokens.videoTileRadius)
                      ),
                      child: Text(id)
                    );
                  }).toList()
                ),
                const SizedBox(height: 8),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  OutlinedButton(
                    onPressed: state.mediaPermissionGranted
                        ? state.toggleCamera
                        : () {
                            state.grantMediaPermission();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.t('video.permissionGranted')))
                            );
                          },
                    child: Text(state.cameraEnabled ? state.t('video.cameraOn') : state.t('video.cameraOff'))
                  ),
                  const SizedBox(width: 8),
                  OutlinedButton(
                    onPressed: state.mediaPermissionGranted
                        ? state.toggleMic
                        : () {
                            state.grantMediaPermission();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(state.t('video.permissionGranted')))
                            );
                          },
                    child: Text(state.micEnabled ? state.t('video.micOn') : state.t('video.micOff'))
                  ),
                  const SizedBox(width: 8),
                  FilledButton(onPressed: state.hangupVideo, child: Text(state.t('video.hangup')))
                ]),
                Text('status: ${state.videoStatus}')
              ])
            )
          )
        )
      )
    );
  }
}

class TileBoardWidget extends StatelessWidget {
  const TileBoardWidget({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Draggable<String>(
          data: state.selectedTile,
          feedback: Material(color: Colors.transparent, child: _tileCell(state.selectedTile, highlight: true)),
          child: _tileCell(state.selectedTile, highlight: true)
        ),
        const SizedBox(width: 8),
        OutlinedButton(onPressed: state.toggleTileSymbol, child: const Text('Switch'))
      ]),
      Expanded(
        child: GridView.builder(
          shrinkWrap: true,
          itemCount: 16,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
          itemBuilder: (_, i) {
            final r = i ~/ 4;
            final c = i % 4;
            final isPreview = state.previewRow == r && state.previewCol == c;
            return DragTarget<String>(
              onWillAcceptWithDetails: (_) {
                state.updatePreview(r, c);
                return true;
              },
              onLeave: (_) => state.updatePreview(null, null),
              onAcceptWithDetails: (_) {
                state.updatePreview(null, null);
                state.confirmTilePlacement(r, c);
              },
              builder: (_, __, ___) => GestureDetector(
                onTap: () => state.confirmTilePlacement(r, c),
                child: _tileCell(state.tileGrid[r][c], highlight: isPreview)
              )
            );
          }
        )
      )
    ]);
  }

  Widget _tileCell(String? value, {required bool highlight}) {
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: highlight ? state.activeBoardHighlight.withOpacity(0.25) : AppTokens.card,
        border: Border.all(color: AppTokens.boardGridLine),
        borderRadius: BorderRadius.circular(8)
      ),
      alignment: Alignment.center,
      child: Text(value ?? '', style: const TextStyle(fontSize: 18))
    );
  }
}

class RollWriteBoardWidget extends StatelessWidget {
  const RollWriteBoardWidget({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text('Dice: [${state.dice[0]}][${state.dice[1]}]'),
      Expanded(
        child: GridView.builder(
          itemCount: 25,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 5),
          itemBuilder: (_, i) {
            final r = i ~/ 5;
            final c = i % 5;
            final canMark = state.rollSheet[r][c] == 0 && r + c + 2 == state.dice[0] + state.dice[1];
            return GestureDetector(
              onTap: () => state.markRollCell(r, c),
              child: Container(
                margin: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  color: canMark ? state.activeBoardHighlight.withOpacity(0.25) : AppTokens.card,
                  border: Border.all(color: AppTokens.boardGridLine),
                  borderRadius: BorderRadius.circular(6)
                ),
                alignment: Alignment.center,
                child: Text(state.rollSheet[r][c] == 1 ? 'X' : '')
              )
            );
          }
        )
      )
    ]);
  }
}

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Column(children: [
        const TabBar(tabs: [Tab(text: 'Games'), Tab(text: 'Skins'), Tab(text: 'Inventory')]),
        Expanded(
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
              children: state.inventoryItems
                  .map((e) => _InventoryTile(state: state, item: e as Map<String, dynamic>))
                  .toList()
            )
          ])
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
          Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), color: color, child: Text('\$${sku['priceSandbox']}')),
          const SizedBox(width: 8),
          if (sku['isNew'] == true) Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), color: AppTokens.storeBadgeNew, child: const Text('NEW'))
        ]),
        trailing: Row(mainAxisSize: MainAxisSize.min, children: [
          OutlinedButton(onPressed: () => state.trySkin(sku['sku'].toString()), child: const Text('Try')),
          const SizedBox(width: 8),
          FilledButton(onPressed: () => state.buySku(sku['sku'].toString()), child: Text(state.t('store.buy'))),
          const SizedBox(width: 8),
          TextButton(onPressed: () => state.applySkin(sku['sku'].toString()), child: const Text('Apply'))
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
          ? FilledButton(onPressed: () => state.applySkin(item['sku'].toString()), child: const Text('Apply'))
          : const SizedBox.shrink()
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) => Center(child: Text('${state.t('profile.title')}: ${state.userId ?? 'guest'}'));
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.state});
  final AppState state;
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTokens.s16),
      children: [
        Text(state.t('settings.title')),
        Text('${state.t('settings.lang')}: ${state.lang.toUpperCase()}'),
        Wrap(
          spacing: AppTokens.s8,
          children: AppStrings.supported
              .map((l) => ChoiceChip(label: Text(l.toUpperCase()), selected: state.lang == l, onSelected: (_) => state.setLang(l)))
              .toList()
        ),
        const SizedBox(height: 12),
        const Text('[SETTINGS] Privacy • Block list • Report')
      ]
    );
  }
}
