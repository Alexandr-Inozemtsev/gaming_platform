import '../../../services/api_client.dart';

class UnityRuntimeSessionManager {
  UnityRuntimeSessionManager(this.api);

  final ApiClient api;

  Future<String> validateSessionInit({
    required String matchId,
    required String userId,
    required Map<String, dynamic> runtime,
  }) async {
    final sessionId = 'unity_${DateTime.now().millisecondsSinceEpoch}';
    final payload = {
      'schemaVersion': 'runtime-sdk/v1',
      'sessionId': sessionId,
      'matchId': matchId,
      'gameId': 'big_walker_demo',
      'userId': userId,
      'runtime': runtime,
      'auth': {'sessionToken': 'dev_session_$userId'}
    };
    await api.runtimeSdkValidateSessionInit(payload);
    return sessionId;
  }

  Future<void> emitLifecycleEvent({
    required String eventName,
    required String sessionId,
    required String matchId,
    required String userId,
    required Map<String, dynamic> runtime,
    Map<String, dynamic> payload = const {},
  }) async {
    await api.trackRuntimeEvent(
      eventName: eventName,
      sessionId: sessionId,
      matchId: matchId,
      userId: userId,
      runtime: runtime,
      payload: payload,
    );
  }
}
