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
const ALLOWED_RUNTIME_PLATFORMS = new Set(['ios', 'android', 'web', 'desktop', 'unknown']);

export const ANALYTICS_ALLOWED_EVENTS = new Set([...BASE_EVENTS, ...RUNTIME_EVENTS]);
export const RUNTIME_SDK_SCHEMA_VERSION = 'runtime-sdk/v1';
export const RUNTIME_EVENT_TAXONOMY = Object.freeze({
  session: Object.freeze([
    'runtime.session.started',
    'runtime.session.paused',
    'runtime.session.resumed',
    'runtime.session.ended'
  ]),
  input: Object.freeze(['runtime.player.input']),
  move: Object.freeze(['runtime.move.requested', 'runtime.move.applied', 'runtime.move.rejected']),
  system: Object.freeze(['runtime.error'])
});

const assertObject = (value, errorCode) => {
  if (typeof value !== 'object' || value === null || Array.isArray(value)) throw new Error(errorCode);
};

const assertNonEmptyString = (value, errorCode, min = 1) => {
  if (typeof value !== 'string' || value.length < min) throw new Error(errorCode);
};

const validateRuntimeDescriptor = (runtime) => {
  assertObject(runtime, 'RUNTIME_PAYLOAD_RUNTIME_REQUIRED');
  if (!ALLOWED_RUNTIME_ENGINES.has(runtime.engine)) throw new Error('RUNTIME_PAYLOAD_ENGINE_UNSUPPORTED');
  if (!ALLOWED_RUNTIME_PLATFORMS.has(runtime.platform)) throw new Error('RUNTIME_PAYLOAD_PLATFORM_UNSUPPORTED');
  assertNonEmptyString(runtime.engineVersion, 'RUNTIME_PAYLOAD_ENGINE_VERSION_REQUIRED');
};

export const validateRuntimeSessionInitPayload = (payload) => {
  assertObject(payload, 'RUNTIME_SESSION_INIT_INVALID_SHAPE');
  if (payload.schemaVersion !== RUNTIME_SDK_SCHEMA_VERSION) throw new Error('RUNTIME_SCHEMA_VERSION_UNSUPPORTED');
  assertNonEmptyString(payload.sessionId, 'RUNTIME_PAYLOAD_SESSION_REQUIRED', 3);
  assertNonEmptyString(payload.matchId, 'RUNTIME_PAYLOAD_MATCH_REQUIRED', 3);
  assertNonEmptyString(payload.gameId, 'RUNTIME_PAYLOAD_GAME_REQUIRED', 3);
  assertNonEmptyString(payload.userId, 'RUNTIME_PAYLOAD_USER_REQUIRED', 3);
  validateRuntimeDescriptor(payload.runtime);
  assertObject(payload.auth, 'RUNTIME_PAYLOAD_AUTH_REQUIRED');
  assertNonEmptyString(payload.auth.sessionToken, 'RUNTIME_PAYLOAD_SESSION_TOKEN_REQUIRED', 10);
};

export const validateRuntimeEventPayload = (eventName, payload) => {
  if (!eventName.startsWith('runtime.')) return;
  assertObject(payload, 'RUNTIME_PAYLOAD_INVALID_SHAPE');
  if (payload.schemaVersion !== RUNTIME_SDK_SCHEMA_VERSION) {
    throw new Error('RUNTIME_SCHEMA_VERSION_UNSUPPORTED');
  }
  validateRuntimeDescriptor(payload.runtime);
  assertNonEmptyString(payload.sessionId, 'RUNTIME_PAYLOAD_SESSION_REQUIRED', 3);
  assertNonEmptyString(payload.matchId, 'RUNTIME_PAYLOAD_MATCH_REQUIRED', 3);
  assertNonEmptyString(payload.ts, 'RUNTIME_PAYLOAD_TS_INVALID');
  if (Number.isNaN(Date.parse(payload.ts))) throw new Error('RUNTIME_PAYLOAD_TS_INVALID');
};
