/**
 * Назначение файла: проверить аналитические события, технические метрики и dashboard в API-слое MVP.
 * Роль в проекте: гарантировать, что Prompt J работает без внешнего провайдера на in-memory данных.
 * Основные функции: проверка track/list/dashboard и обязательных доменных событий при login/match/store/report.
 * Связи с другими файлами: использует services/api/src/app.mjs и дополняет smoke-набор тестов API.
 * Важно при изменении: сохранять список поддерживаемых eventName синхронно с backend-контрактом.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { createApiApp } from '../src/app.mjs';

test('analytics: доменные события записываются автоматически', () => {
  const app = createApiApp({ config: { DEFAULT_LANG: 'ru' } });
  const user = app.auth.register({ email: 'analytics@test.dev', password: 'secret01' });
  app.auth.login({ email: 'analytics@test.dev', password: 'secret01' });
  const match = app.matches.create({ gameId: 'tile_placement_demo', players: [user.id, `${user.id}_bot`] });
  app.matches.move({
    matchId: match.id,
    playerId: user.id,
    action: 'place',
    moveId: 'analytics-m1',
    payload: { row: 0, col: 0 }
  });
  app.store.skus();
  app.store.purchaseSandbox({ userId: user.id, sku: 'skin.dice.neon' });
  app.moderation.report({ reporterUserId: user.id, targetType: 'chat', targetId: 'm1', reason: 'spam-msg' });

  const events = app.analytics.list({ limit: 50 });
  const names = events.map((e) => e.eventName);
  assert.equal(names.includes('onboarding_complete'), true);
  assert.equal(names.includes('login_success'), true);
  assert.equal(names.includes('match_create'), true);
  assert.equal(names.includes('match_move'), true);
  assert.equal(names.includes('latency_move'), true);
  assert.equal(names.includes('store_view'), true);
  assert.equal(names.includes('purchase_attempt'), true);
  assert.equal(names.includes('purchase_success'), true);
  assert.equal(names.includes('report_sent'), true);
});

test('analytics: track/list/dashboard и технические метрики', () => {
  const app = createApiApp({ config: { DEFAULT_LANG: 'ru' } });
  const user = app.auth.register({ email: 'analytics-metric@test.dev', password: 'secret01' });

  const tracked = app.analytics.track({
    eventName: 'ws_disconnects',
    userId: user.id,
    payload: { reason: 'network' },
    source: 'client'
  });
  assert.equal(tracked.ok, true);

  const metric = app.analytics.incMetric('wsDisconnects');
  assert.equal(metric.ok, true);

  const dashboard = app.analytics.dashboard();
  assert.equal(typeof dashboard.matches7d, 'number');
  assert.equal(Array.isArray(dashboard.dauProxy), true);
  assert.equal(dashboard.technical.wsDisconnects >= 1, true);
});

test('analytics: runtime-sdk v1 события валидируются', () => {
  const app = createApiApp({ config: { DEFAULT_LANG: 'ru' } });
  const user = app.auth.register({ email: 'analytics-runtime@test.dev', password: 'secret01' });

  const accepted = app.analytics.track({
    eventName: 'runtime.session.started',
    userId: user.id,
    source: 'runtime',
    payload: {
      schemaVersion: 'runtime-sdk/v1',
      sessionId: 'sess_runtime_001',
      matchId: 'match_runtime_001',
      runtime: { engine: 'unity', engineVersion: '2022.3.54f1', platform: 'android' },
      ts: new Date().toISOString(),
      payload: { scene: 'main' }
    }
  });
  assert.equal(accepted.ok, true);

  assert.throws(
    () =>
      app.analytics.track({
        eventName: 'runtime.move.applied',
        userId: user.id,
        source: 'runtime',
        payload: {
          schemaVersion: 'runtime-sdk/v0',
          sessionId: 'sess_runtime_001',
          matchId: 'match_runtime_001',
          runtime: { engine: 'unity', engineVersion: '2022.3.54f1', platform: 'android' },
          ts: new Date().toISOString(),
          payload: { moveId: 'm1' }
        }
      }),
    /RUNTIME_SCHEMA_VERSION_UNSUPPORTED/
  );
});
