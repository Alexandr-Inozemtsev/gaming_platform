import test from 'node:test';
import assert from 'node:assert/strict';
import { createApiApp } from '../src/app.mjs';

const validSessionInit = {
  schemaVersion: 'runtime-sdk/v1',
  sessionId: 'sess_001',
  matchId: 'match_001',
  gameId: 'big_walker_demo',
  userId: 'user_001',
  runtime: {
    engine: 'unity',
    engineVersion: '2022.3.54f1',
    platform: 'android'
  },
  auth: {
    sessionToken: 'token_0123456789'
  }
};

test('runtime-sdk: events taxonomy and validation API in app layer', () => {
  const app = createApiApp({ config: { DEFAULT_LANG: 'ru' } });

  const events = app.runtimeSdk.events();
  assert.equal(events.schemaVersion, 'runtime-sdk/v1');
  assert.equal(Array.isArray(events.taxonomy.session), true);
  assert.equal(events.all.includes('runtime.session.started'), true);

  const validatedInit = app.runtimeSdk.validateSessionInit(validSessionInit);
  assert.equal(validatedInit.ok, true);

  const validatedEnvelope = app.runtimeSdk.validateEventEnvelope({
    eventName: 'runtime.move.applied',
    payload: {
      schemaVersion: 'runtime-sdk/v1',
      sessionId: 'sess_001',
      matchId: 'match_001',
      runtime: {
        engine: 'unity',
        engineVersion: '2022.3.54f1',
        platform: 'android'
      },
      ts: new Date().toISOString(),
      payload: { moveId: 'm1' }
    }
  });
  assert.equal(validatedEnvelope.ok, true);
});

test('runtime-sdk: invalid session init fails with contract error code', () => {
  const app = createApiApp({ config: { DEFAULT_LANG: 'ru' } });
  assert.throws(
    () =>
      app.runtimeSdk.validateSessionInit({
        ...validSessionInit,
        auth: { sessionToken: 'short' }
      }),
    /RUNTIME_PAYLOAD_SESSION_TOKEN_REQUIRED/
  );
});
