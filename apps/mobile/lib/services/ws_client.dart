// Назначение файла: реализовать минимальный WebSocket-клиент для realtime событий игровой комнаты и signaling WebRTC.
// Роль в проекте: отделить работу с сокетом от виджетов и дать простую подписку на входящие сообщения.
// Основные функции: connect/disconnect, отправка сообщений, поток входящих событий и вспомогательные методы video.offer/video.answer/video.iceCandidate.
// Связи с другими файлами: используется в AppState (main.dart) для обновления лога/чата и обмена signaling внутри приватной комнаты.
// Важно при изменении: корректно закрывать соединение, сохранять формат payload для signaling и не логировать секреты TURN.

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

  void sendVideoOffer({required String roomId, required String fromUserId, required String targetUserId, required String sdp}) {
    send({
      'type': 'video.offer',
      'roomId': roomId,
      'userId': fromUserId,
      'targetUserId': targetUserId,
      'payload': {'sdp': sdp}
    });
  }

  void sendVideoAnswer({required String roomId, required String fromUserId, required String targetUserId, required String sdp}) {
    send({
      'type': 'video.answer',
      'roomId': roomId,
      'userId': fromUserId,
      'targetUserId': targetUserId,
      'payload': {'sdp': sdp}
    });
  }

  void sendVideoIceCandidate({
    required String roomId,
    required String fromUserId,
    required String targetUserId,
    required String candidate,
    required String sdpMid,
    required int sdpMLineIndex
  }) {
    send({
      'type': 'video.iceCandidate',
      'roomId': roomId,
      'userId': fromUserId,
      'targetUserId': targetUserId,
      'payload': {'candidate': candidate, 'sdpMid': sdpMid, 'sdpMLineIndex': sdpMLineIndex}
    });
  }

  Future<void> disconnect() async {
    await _socket?.close();
    _socket = null;
  }
}
