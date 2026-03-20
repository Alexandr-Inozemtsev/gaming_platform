// Назначение файла: предоставить минимальный e2e smoke-тест Flutter для пользовательского пути login -> catalog -> room.
// Роль в проекте: проверять, что базовый UX поток работает при подмене сетевого слоя без реального backend.
// Основные функции: фейковый ApiClient/WsClient, авторизация через AuthScreen, переходы по нижней навигации до комнаты.
// Связи с другими файлами: использует apps/mobile/lib/main.dart и сервисные клиенты из apps/mobile/lib/services/.
// Важно при изменении: сохранять локаль-независимые проверки через иконки и не использовать внешнюю сеть в тесте.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tabletopplatform_mobile/main.dart';
import 'package:tabletopplatform_mobile/services/api_client.dart';
import 'package:tabletopplatform_mobile/services/ws_client.dart';

class _FakeApiClient extends ApiClient {
  _FakeApiClient() : super('http://fake.local');

  @override
  Future<Map<String, dynamic>> login(String email, String password) async => {
    'user': {'id': 'u_test'}
  };

  @override
  Future<Map<String, dynamic>> register(String email, String password) async => {'id': 'u_test'};

  @override
  Future<List<dynamic>> games() async => const [
    {'id': 'tile_placement_demo', 'title': 'Tile Placement Demo'}
  ];

  @override
  Future<Map<String, dynamic>> storeSkus() async => {
    'regionMode': 'global',
    'warning': null,
    'items': []
  };

  @override
  Future<List<dynamic>> inventory(String userId) async => const [];

  @override
  Future<List<dynamic>> myVariants(String userId) async => const [];

  @override
  Future<Map<String, dynamic>> analyticsDashboard() async => {'matches7d': 1, 'dauProxy': []};

  @override
  Future<List<dynamic>> analyticsEvents({int limit = 200}) async => const [];

  @override
  Future<Map<String, dynamic>> createMatch(String gameId, List<String> players, {String? variantId}) async => {
    'id': 'match_fake_1',
    'gameId': gameId
  };
}

class _FakeWsClient extends WsClient {
  _FakeWsClient() : super('ws://fake.local');

  final StreamController<Map<String, dynamic>> _controller = StreamController.broadcast();

  @override
  Stream<Map<String, dynamic>> get events => _controller.stream;

  @override
  Future<void> connect() async {}

  @override
  void send(Map<String, dynamic> payload) {}

  @override
  Future<void> disconnect() async {
    await _controller.close();
  }
}

void main() {
  testWidgets('smoke: login -> open catalog -> open game room', (tester) async {
    final state = AppState(apiClient: _FakeApiClient(), wsClient: _FakeWsClient());
    state.games = const [
      {'id': 'tile_placement_demo', 'title': 'Tile Placement Demo'}
    ];

    await tester.pumpWidget(
      AnimatedBuilder(
        animation: state,
        builder: (context, _) => MaterialApp(home: state.authorized ? MainShell(state: state) : AuthScreen(state: state))
      )
    );

    await tester.pumpAndSettle();

    // Нажимаем вход на экране авторизации, чтобы пройти шаг login в smoke-пути.
    await tester.tap(find.widgetWithText(FilledButton, 'Войти'));
    await tester.pumpAndSettle();

    // Переходим в каталог через иконку, чтобы тест не зависел от RU/EN строк.
    await tester.tap(find.byIcon(Icons.grid_view));
    await tester.pumpAndSettle();
    expect(find.text('Join'), findsWidgets);

    // Переходим в комнату и проверяем, что экран комнаты отрисовался.
    await tester.tap(find.byIcon(Icons.meeting_room));
    await tester.pumpAndSettle();
    expect(find.textContaining('tile_placement_demo'), findsWidgets);
  });
}
