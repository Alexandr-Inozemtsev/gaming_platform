// Назначение файла: собрать MVP Flutter-приложение в одном месте (навигация, состояние, экраны, базовая интеграция API/WS).
// Роль в проекте: быть исполняемой точкой входа mobile-клиента TabletopPlatform для сценариев onboarding/auth/home/catalog/room/store/profile/settings.
// Основные функции: инициализация AppState, переключение вкладок с fade-анимацией, пульсация "твой ход", i18n RU/EN и sandbox purchase.
// Связи с другими файлами: использует theme/tokens.dart, services/api_client.dart, services/ws_client.dart и i18n/strings.dart.
// Важно при изменении: не смешивать UI-логику и сетевой слой; все сетевые ошибки обрабатывать мягко, чтобы MVP оставался интерактивным офлайн.

import 'dart:async';

import 'package:flutter/material.dart';

import 'i18n/strings.dart';
import 'services/api_client.dart';
import 'services/ws_client.dart';
import 'theme/tokens.dart';

const String apiBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: 'http://localhost:3000');
const String wsUrl = String.fromEnvironment('WS_URL', defaultValue: 'ws://localhost:3001');

void main() {
  runApp(const TabletopApp());
}

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
  String? roomId;
  final List<String> roomLog = [];
  final List<String> chat = [];
  bool yourTurn = true;

  StreamSubscription<Map<String, dynamic>>? _wsSub;

  String t(String key) => AppStrings.t(lang, key);

  Future<void> init() async {
    await ws.connect();
    _wsSub = ws.events.listen((event) {
      roomLog.add('WS: ${event['type'] ?? 'event'}');
      notifyListeners();
    });
    games = await api.games();
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

  Future<void> loginOrRegister(String email, String password, {required bool register}) async {
    final result = register ? await api.register(email, password) : await api.login(email, password);
    userId = (result['user']?['id'] ?? result['id'])?.toString();
    authorized = true;
    notifyListeners();
  }

  Future<void> createPrivateRoom(String gameId) async {
    if (userId == null) return;
    final result = await api.createMatch(gameId, [userId!, '${userId!}_bot']);
    roomId = result['id']?.toString();
    roomLog.add('Room created: $roomId');
    tab = 2;
    notifyListeners();
  }

  void sendChat(String text) {
    chat.add(text);
    ws.send({'type': 'chat.message', 'text': text, 'roomId': roomId});
    notifyListeners();
  }

  void applyLocalMove() {
    yourTurn = !yourTurn;
    roomLog.add(yourTurn ? 'Turn switched: your turn' : 'Turn switched: opponent');
    notifyListeners();
  }

  Future<void> sandboxPurchase() async {
    if (userId == null) return;
    await api.purchaseSandbox(userId!, 'dice_skin_001');
    roomLog.add('Sandbox purchase completed');
    notifyListeners();
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
      builder: (context, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'TabletopPlatform',
          theme: AppTheme.build(),
          home: state.authorized ? MainShell(state: state) : AuthScreen(state: state)
        );
      }
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
      body: Padding(
        padding: const EdgeInsets.all(AppTokens.s24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTokens.s16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(register ? widget.state.t('auth.register') : widget.state.t('auth.login'),
                        style: Theme.of(context).textTheme.headlineSmall),
                    const SizedBox(height: AppTokens.s12),
                    TextField(controller: email, decoration: InputDecoration(labelText: widget.state.t('auth.email'))),
                    const SizedBox(height: AppTokens.s12),
                    TextField(controller: password, decoration: InputDecoration(labelText: widget.state.t('auth.password'))),
                    const SizedBox(height: AppTokens.s16),
                    ElevatedButton(
                      onPressed: () async {
                        await widget.state.loginOrRegister(email.text.trim(), password.text.trim(), register: register);
                      },
                      child: Text(register ? widget.state.t('auth.register') : widget.state.t('auth.login'))
                    ),
                    TextButton(
                      onPressed: () => setState(() => register = !register),
                      child: Text(register ? widget.state.t('auth.login') : widget.state.t('auth.register'))
                    )
                  ]
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(state.t('home.continue')),
              const SizedBox(height: AppTokens.s12),
              Row(children: [
                FilledButton(onPressed: () => state.setTab(2), child: Text(state.t('home.play'))),
                const SizedBox(width: AppTokens.s12),
                OutlinedButton(
                  onPressed: () => state.createPrivateRoom('tile_placement_demo'),
                  child: Text(state.t('home.createRoom'))
                )
              ]),
              const SizedBox(height: AppTokens.s12),
              Text(state.t('home.teaser'), style: Theme.of(context).textTheme.bodySmall)
            ]
          )
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
    return ListView.builder(
      padding: const EdgeInsets.all(AppTokens.s16),
      itemCount: state.games.length,
      itemBuilder: (_, i) {
        final game = state.games[i] as Map<String, dynamic>;
        return Card(
          child: ListTile(
            title: Text(game['title']?.toString() ?? game['id'].toString()),
            subtitle: Text(game['id'].toString()),
            trailing: FilledButton(
              onPressed: () => state.createPrivateRoom(game['id'].toString()),
              child: Text(state.t('home.createRoom'))
            )
          )
        );
      }
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
  late final AnimationController pulse = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
    ..repeat(reverse: true);
  final chat = TextEditingController();

  @override
  void dispose() {
    pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTokens.s16),
      child: Column(
        children: [
          Expanded(
            flex: 2,
            child: Card(
              child: Center(
                child: AnimatedBuilder(
                  animation: pulse,
                  builder: (_, __) {
                    final opacity = widget.state.yourTurn ? (0.45 + pulse.value * 0.55) : 0.3;
                    return Container(
                      width: 220,
                      height: 120,
                      decoration: BoxDecoration(
                        color: AppTokens.accent.withOpacity(opacity),
                        borderRadius: BorderRadius.circular(AppTokens.radiusCard)
                      ),
                      alignment: Alignment.center,
                      child: Text(widget.state.t('room.yourTurn'))
                    );
                  }
                )
              )
            )
          ),
          const SizedBox(height: AppTokens.s12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    child: ListView(
                      padding: const EdgeInsets.all(AppTokens.s12),
                      children: widget.state.roomLog.map((e) => Text('• $e')).toList()
                    )
                  )
                ),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: Card(
                    child: Column(children: [
                      Expanded(
                        child: ListView(
                          padding: const EdgeInsets.all(AppTokens.s12),
                          children: widget.state.chat.map((e) => Text('💬 $e')).toList()
                        )
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppTokens.s8),
                        child: Row(children: [
                          Expanded(child: TextField(controller: chat, decoration: const InputDecoration(hintText: 'chat'))),
                          IconButton(
                            onPressed: () {
                              widget.state.sendChat(chat.text);
                              chat.clear();
                            },
                            icon: const Icon(Icons.send)
                          )
                        ])
                      )
                    ])
                  )
                )
              ]
            )
          ),
          const SizedBox(height: AppTokens.s8),
          Row(children: [
            FilledButton(onPressed: widget.state.applyLocalMove, child: const Text('Action')),
            const SizedBox(width: AppTokens.s12),
            Text(widget.state.roomId == null ? 'no room' : 'Room: ${widget.state.roomId}')
          ])
        ]
      )
    );
  }
}

class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const TabBar(tabs: [Tab(text: 'Games'), Tab(text: 'Skins')]),
          Expanded(
            child: TabBarView(
              children: [
                _StoreCard(title: 'Game Pack', action: state.t('store.buy'), onPressed: state.sandboxPurchase),
                _StoreCard(title: 'Dice Skin', action: state.t('store.buy'), onPressed: state.sandboxPurchase)
              ]
            )
          )
        ]
      )
    );
  }
}

class _StoreCard extends StatelessWidget {
  const _StoreCard({required this.title, required this.action, required this.onPressed});
  final String title;
  final String action;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppTokens.s16),
      child: Card(
        child: ListTile(
          title: Text(title),
          subtitle: const Text('sandbox item'),
          trailing: FilledButton(onPressed: onPressed, child: Text(action))
        )
      )
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return Center(child: Text('${state.t('profile.title')}: ${state.userId ?? 'guest'}'));
  }
}

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key, required this.state});
  final AppState state;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppTokens.s16),
      children: [
        Text(state.t('settings.title'), style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: AppTokens.s12),
        Text('${state.t('settings.lang')}: ${state.lang.toUpperCase()}'),
        Wrap(
          spacing: AppTokens.s8,
          children: AppStrings.supported
              .map((l) => ChoiceChip(label: Text(l.toUpperCase()), selected: state.lang == l, onSelected: (_) => state.setLang(l)))
              .toList()
        ),
        const SizedBox(height: AppTokens.s16),
        const Text('[SETTINGS] Privacy • Block list • Report')
      ]
    );
  }
}
