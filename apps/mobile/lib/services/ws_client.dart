// Назначение файла: реализовать минимальный WebSocket-клиент для realtime событий игровой комнаты.
// Роль в проекте: отделить работу с сокетом от виджетов и дать простую подписку на входящие сообщения.
// Основные функции: connect/disconnect, отправка сообщений и поток входящих событий.
// Связи с другими файлами: используется в AppState (main.dart) для обновления лога/чата в Game Room.
// Важно при изменении: корректно закрывать соединение, чтобы не оставлять висящие сокеты при навигации.

import 'dart:async';
import 'dart:convert';
import 'dart:io';

class WsClient {
  WsClient(this.url);

  final String url;
  final StreamController<Map<String, dynamic>> _events = StreamController.broadcast();
  WebSocket? _socket;

  Stream<Map<String, dynamic>> get events => _events.stream;

  Future<void> connect() async {
    try {
      _socket = await WebSocket.connect(url);
      _socket!.listen((event) {
        if (event is String) {
          try {
            _events.add(jsonDecode(event) as Map<String, dynamic>);
          } catch (_) {
            _events.add({'type': 'raw', 'payload': event});
          }
        }
      });
    } catch (_) {
      _events.add({'type': 'offline', 'payload': 'ws_unavailable'});
    }
  }

  void send(Map<String, dynamic> payload) {
    _socket?.add(jsonEncode(payload));
  }

  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
  }
}
