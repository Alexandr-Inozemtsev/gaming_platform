// Назначение файла: реализовать минимальный HTTP-клиент для интеграции Flutter MVP с backend API.
// Роль в проекте: изолировать сетевые вызовы от UI, чтобы экраны работали через единый слой данных.
// Основные функции: login/register, games list, create room(match), sandbox purchase.
// Связи с другими файлами: используется в main.dart через AppState; базовый URL приходит из константы API_BASE_URL.
// Важно при изменении: учитывать, что в MVP допустим fallback на мок-данные при недоступности API.

import 'dart:convert';
import 'dart:io';

class ApiClient {
  ApiClient(this.baseUrl);

  final String baseUrl;

  Future<Map<String, dynamic>> login(String email, String password) async {
    return _post('/auth/login', {'email': email, 'password': password});
  }

  Future<Map<String, dynamic>> register(String email, String password) async {
    return _post('/auth/register', {'email': email, 'password': password});
  }

  Future<List<dynamic>> games() async {
    try {
      final uri = Uri.parse('$baseUrl/games');
      final client = HttpClient();
      final req = await client.getUrl(uri);
      final res = await req.close();
      final body = await utf8.decodeStream(res);
      if (res.statusCode >= 200 && res.statusCode < 300) {
        return jsonDecode(body) as List<dynamic>;
      }
    } catch (_) {}
    return const [
      {'id': 'tile_placement_demo', 'title': 'Tile Placement Demo'},
      {'id': 'roll_and_write_demo', 'title': 'Roll & Write Demo'}
    ];
  }

  Future<Map<String, dynamic>> createMatch(String gameId, List<String> players) async {
    return _post('/matches', {'gameId': gameId, 'players': players});
  }

  Future<Map<String, dynamic>> purchaseSandbox(String userId, String sku) async {
    return _post('/store/purchase-sandbox', {'userId': userId, 'sku': sku});
  }

  Future<Map<String, dynamic>> _post(String path, Map<String, dynamic> payload) async {
    final uri = Uri.parse('$baseUrl$path');
    final client = HttpClient();
    final req = await client.postUrl(uri);
    req.headers.set('content-type', 'application/json');
    req.write(jsonEncode(payload));
    final res = await req.close();
    final body = await utf8.decodeStream(res);
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return (body.isEmpty ? {} : jsonDecode(body)) as Map<String, dynamic>;
    }
    throw Exception('HTTP ${res.statusCode}: $body');
  }
}
