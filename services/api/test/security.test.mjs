/**
 * Назначение файла: проверить security-требования Prompt D/F на уровне app-логики.
 * Роль в проекте: гарантировать корректные статусы ошибок для идемпотентности, очередности и rate-limit.
 * Основные функции: 409 duplicate moveId, 403 not your turn, 429 rate-limit login/move.
 * Связи с другими файлами: использует services/api/src/app.mjs.
 * Важно при изменении: сохранять точные коды ошибок, так как они являются публичным контрактом.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { createApiApp } from '../src/app.mjs';

const setup = (config = {}) => {
  const app = createApiApp({ config: { DEFAULT_LANG: 'ru', ...config } });
  const u1 = app.auth.register({ email: `u1_${Math.random()}@test.dev`, password: 'secret01' });
  const u2 = app.auth.register({ email: `u2_${Math.random()}@test.dev`, password: 'secret02' });
  const match = app.matches.create({ gameId: 'tile_placement_demo', players: [u1.id, u2.id] });
  return { app, u1, u2, match };
};

test('повторный moveId -> 409', () => {
  const { app, u1, u2, match } = setup();
  app.matches.move({ matchId: match.id, playerId: u1.id, action: 'place', moveId: 'same', payload: { row: 0, col: 0 } });
  assert.throws(
    () => app.matches.move({ matchId: match.id, playerId: u2.id, action: 'place', moveId: 'same', payload: { row: 0, col: 1 } }),
    (e) => e.status === 409
  );
});

test('ход не в свой ход -> 403', () => {
  const { app, u2, match } = setup();
  assert.throws(
    () => app.matches.move({ matchId: match.id, playerId: u2.id, action: 'place', moveId: 'bad', payload: { row: 0, col: 0 } }),
    (e) => e.status === 403
  );
});

test('rate-limit login -> 429', () => {
  const app = createApiApp({ config: { RATE_LIMIT_LOGIN: 1 } });
  app.auth.register({ email: 'rate_login@test.dev', password: 'secret01' });
  app.auth.login({ email: 'rate_login@test.dev', password: 'secret01', ip: '2.2.2.2' });
  assert.throws(
    () => app.auth.login({ email: 'rate_login@test.dev', password: 'secret01', ip: '2.2.2.2' }),
    (e) => e.status === 429
  );
});

test('rate-limit move -> 429', () => {
  const { app, u1, u2, match } = setup({ RATE_LIMIT_MOVE: 1 });
  app.matches.move({ matchId: match.id, playerId: u1.id, action: 'place', moveId: 'm1', payload: { row: 0, col: 0 } });
  app.matches.move({ matchId: match.id, playerId: u2.id, action: 'place', moveId: 'm2', payload: { row: 0, col: 1 } });
  assert.throws(
    () => app.matches.move({ matchId: match.id, playerId: u1.id, action: 'place', moveId: 'm3', payload: { row: 1, col: 0 } }),
    (e) => e.status === 429
  );
});
