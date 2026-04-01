/**
 * Runtime SDK v1 contract primitives.
 */

const BASE_EVENTS = [
  'onboarding_complete',
  'login_success',
  'match_create',
  'match_move',
  'match_finish',
  'store_view',
  'purchase_attempt',
  'purchase_success',
  'variant_publish',
  'report_sent',
  'latency_move',
  'level_complete',
  'campaign_finished',
  'reconnect_count',
  'ws_disconnects',
  'video_connect_failures'
];

const RUNTIME_EVENTS = [
  'runtime.session.started',
  'runtime.session.paused',
  'runtime.session.resumed',
  'runtime.session.ended',
  'runtime.player.input',
  'runtime.move.requested',
  'runtime.move.applied',
  'runtime.move.rejected',
  'runtime.error'
];

const ALLOWED_RUNTIME_ENGINES = new Set(['unity', 'flutter', 'webgl', 'unknown']);

export const ANALYTICS_ALLOWED_EVENTS = new Set([...BASE_EVENTS, ...RUNTIME_EVENTS]);
export const RUNTIME_SDK_SCHEMA_VERSION = 'runtime-sdk/v1';

export const validateRuntimeEventPayload = (eventName, payload) => {
  if (!eventName.startsWith('runtime.')) return;
  if (typeof payload !== 'object' || payload === null || Array.isArray(payload)) {
    throw new Error('RUNTIME_PAYLOAD_INVALID_SHAPE');
  }
  if (payload.schemaVersion !== RUNTIME_SDK_SCHEMA_VERSION) {
    throw new Error('RUNTIME_SCHEMA_VERSION_UNSUPPORTED');
  }
  const runtime = payload.runtime;
  if (typeof runtime !== 'object' || runtime === null) throw new Error('RUNTIME_PAYLOAD_RUNTIME_REQUIRED');
  if (!ALLOWED_RUNTIME_ENGINES.has(runtime.engine)) throw new Error('RUNTIME_PAYLOAD_ENGINE_UNSUPPORTED');
  if (typeof payload.sessionId !== 'string' || payload.sessionId.length < 3) throw new Error('RUNTIME_PAYLOAD_SESSION_REQUIRED');
  if (typeof payload.matchId !== 'string' || payload.matchId.length < 3) throw new Error('RUNTIME_PAYLOAD_MATCH_REQUIRED');
  if (typeof payload.ts !== 'string' || Number.isNaN(Date.parse(payload.ts))) throw new Error('RUNTIME_PAYLOAD_TS_INVALID');
};
