// Назначение файла: реализовать минимальный HTTP-клиент для интеграции Flutter MVP с backend API.
// Роль в проекте: изолировать сетевые вызовы от UI, чтобы экраны работали через единый слой данных.
// Основные функции: auth, games, создание матча, store skus/purchase/apply-skin, inventory.
// Связи с другими файлами: используется в main.dart через AppState; базовый URL приходит из константы API_BASE_URL.
// Важно при изменении: сохранять fallback для MVP-оффлайна и не дублировать бизнес-правила store в клиенте.

import 'dart:convert';
import 'dart:io';

class ApiClient {
  ApiClient(this.baseUrl);

  final String baseUrl;

  Future<Map<String, dynamic>> login(String email, String password) async => _post('/auth/login', {'email': email, 'password': password});
  Future<Map<String, dynamic>> register(String email, String password) async => _post('/auth/register', {'email': email, 'password': password});

  Future<List<dynamic>> games() async {
    try {
      final body = await _get('/games');
      return body as List<dynamic>;
    } catch (_) {
      return const [
        {'id': 'tile_placement_demo', 'title': 'Tile Placement Demo'},
        {'id': 'roll_and_write_demo', 'title': 'Roll & Write Demo'}
      ];
    }
  }

  Future<Map<String, dynamic>> storeSkus() async {
    try {
      return (await _get('/store/skus')) as Map<String, dynamic>;
    } catch (_) {
      return {
        'regionMode': 'global',
        'warning': null,
        'items': [
          {'sku': 'skin.dice.neon', 'title': 'Dice Neon Skin', 'type': 'COSMETIC', 'priceSandbox': 1.49, 'isNew': true}
        ]
      };
    }
  }

  Future<List<dynamic>> inventory(String userId) async {
    try {
      final body = await _get('/inventory?userId=$userId');
      return body as List<dynamic>;
    } catch (_) {
      return const [];
    }
  }

  Future<Map<String, dynamic>> createMatch(String gameId, List<String> players) async => _post('/matches', {'gameId': gameId, 'players': players});
  Future<Map<String, dynamic>> purchaseSandbox(String userId, String sku) async => _post('/store/purchase-sandbox', {'userId': userId, 'sku': sku});
  Future<Map<String, dynamic>> applySkin(String userId, String sku) async => _post('/store/apply-skin', {'userId': userId, 'sku': sku});

  Future<dynamic> _get(String path) async {
    final uri = Uri.parse('$baseUrl$path');
    final client = HttpClient();
    final req = await client.getUrl(uri);
    final res = await req.close();
    final body = await utf8.decodeStream(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return body.isEmpty ? {} : jsonDecode(body);
    throw Exception('HTTP ${res.statusCode}: $body');
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl$path');
    final client = HttpClient();
    final req = await client.postUrl(uri);
    req.headers.set('content-type', 'application/json');
    req.write(jsonEncode(payload));
    final res = await req.close();
    final body = await utf8.decodeStream(res);
    if (res.statusCode >= 200 && res.statusCode < 300) return (body.isEmpty ? {} : jsonDecode(body)) as Map<String, dynamic>;
    throw Exception('HTTP ${res.statusCode}: $body');
  }
}
