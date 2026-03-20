// Назначение файла: реализовать клиент аналитики с batching для отправки событий в backend API.
// Роль в проекте: отделить трекинг продуктовых/технических событий от UI и состояния экранов.
// Основные функции: enqueue событий, периодический flush батча, отправка технических метрик.
// Связи с другими файлами: используется в AppState (main.dart) и опирается на ApiClient.
// Важно при изменении: не блокировать UI сетевыми ошибками и не терять порядок событий внутри батча.

import 'dart:async';

import 'api_client.dart';

class AnalyticsClient {
  AnalyticsClient(this.api, {this.flushInterval = const Duration(seconds: 3), this.batchSize = 10});

  final ApiClient api;
  final Duration flushInterval;
  final int batchSize;
  final List<Map<String, dynamic>> _queue = [];
  Timer? _timer;

  void start() {
    _timer ??= Timer.periodic(flushInterval, (_) => flush());
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
  }

  void enqueue({required String eventName, String? userId, Map<String, dynamic> payload = const {}}) {
    _queue.add({'eventName': eventName, 'userId': userId, 'payload': payload, 'source': 'client'});
    if (_queue.length >= batchSize) {
      unawaited(flush());
    }
  }

  Future<void> flush() async {
    if (_queue.isEmpty) return;
    final batch = _queue.take(batchSize).toList();
    _queue.removeRange(0, batch.length);
    for (final item in batch) {
      try {
        await api.trackAnalyticsEvent(
          eventName: item['eventName'].toString(),
          userId: item['userId']?.toString(),
          payload: (item['payload'] as Map?)?.cast<String, dynamic>() ?? const {},
          source: 'client'
        );
      } catch (_) {
        _queue.insert(0, item);
      }
    }
  }

  Future<void> incrementMetric(String name) async {
    try {
      await api.incrementTechnicalMetric(name);
    } catch (_) {
      // Ошибка метрики не должна ломать игровой поток MVP-клиента.
    }
  }
}
