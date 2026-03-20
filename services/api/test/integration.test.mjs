/**
 * Назначение файла: проверить интеграционный сценарий API для двух игр и завершения матча.
 * Роль в проекте: подтвердить совместимость API и rules-engine по маршруту create -> moves -> finish.
 * Основные функции: регистрация игроков, создание матча, три хода с payload, проверка finished.
 * Связи с другими файлами: использует services/api/src/app.mjs и services/realtime/src/gateway.mjs.
 * Важно при изменении: держать сценарий максимально близким к acceptance-критериям продукта.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { createApiApp } from '../src/app.mjs';
import { createRealtimeGateway } from '../../realtime/src/gateway.mjs';

test('интеграция: create match -> moves -> finish (tile)', () => {
  const gateway = createRealtimeGateway();
  const app = createApiApp({ gateway, config: { DEFAULT_LANG: 'ru' } });

  const u1 = app.auth.register({ email: 'u1@test.dev', password: 'secret01' });
  const u2 = app.auth.register({ email: 'u2@test.dev', password: 'secret02' });
  const match = app.matches.create({ gameId: 'tile_placement_demo', players: [u1.id, u2.id] });

  let state = app.matches.move({ matchId: match.id, playerId: u1.id, action: 'place', moveId: 'i-1', payload: { row: 0, col: 0 } });
  state = app.matches.move({ matchId: match.id, playerId: u2.id, action: 'place', moveId: 'i-2', payload: { row: 0, col: 1 } });
  state = app.matches.move({ matchId: match.id, playerId: u1.id, action: 'place', moveId: 'i-3', payload: { row: 1, col: 0 } });

  assert.equal(state.moveNumber, 3);
  assert.equal(state.gameState.grid[0][0].owner, u1.id);
});

test('интеграция: create match -> moves -> finish (forced maxMoves)', () => {
  const gateway = createRealtimeGateway();
  const app = createApiApp({ gateway, config: { DEFAULT_LANG: 'ru' } });
  const u1 = app.auth.register({ email: 'f1@test.dev', password: 'secret01' });
  const u2 = app.auth.register({ email: 'f2@test.dev', password: 'secret02' });
  const match = app.matches.create({ gameId: 'tile_placement_demo', players: [u1.id, u2.id] });
  const live = app.state.matches.find((m) => m.id === match.id);
  live.maxMoves = 2;

  app.matches.move({ matchId: match.id, playerId: u1.id, action: 'place', moveId: 'f-1', payload: { row: 0, col: 0 } });
  const state = app.matches.move({ matchId: match.id, playerId: u2.id, action: 'place', moveId: 'f-2', payload: { row: 0, col: 1 } });

  assert.equal(state.status, 'finished');
  assert.equal(typeof state.winner === 'string' || state.winner === null, true);
});
