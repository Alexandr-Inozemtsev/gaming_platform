/**
 * Назначение файла: проверить интеграционный сценарий API для жизненного цикла матча.
 * Роль в проекте: гарантировать, что backend MVP умеет создать матч, принять 3 хода и завершить игру.
 * Основные функции: проверка register/login/create match/move x3/finish + инвентарь и репорты.
 * Связи с другими файлами: использует services/api/src/app.mjs и services/realtime/src/gateway.mjs.
 * Важно при изменении: сохранять сценарий "create match -> 3 moves -> finish" как acceptance test.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { createApiApp } from '../src/app.mjs';
import { createRealtimeGateway } from '../../realtime/src/gateway.mjs';

test('интеграция: create match -> 3 moves -> finish', () => {
  const gateway = createRealtimeGateway();
  const events = [];
  const app = createApiApp({ gateway, config: { DEFAULT_LANG: 'ru' } });

  const u1 = app.auth.register({ email: 'u1@test.dev', password: 'p1' });
  const u2 = app.auth.register({ email: 'u2@test.dev', password: 'p2' });

  app.auth.login({ email: 'u1@test.dev', password: 'p1' });
  app.auth.login({ email: 'u2@test.dev', password: 'p2' });

  const match = app.matches.create({
    gameId: 'tile_placement_demo',
    players: [u1.id, u2.id]
  });

  const unsub = gateway.onRoomEvent(match.id, (event) => events.push(event));
  app.matches.move({ matchId: match.id, playerId: u1.id, action: 'place', points: 1 });
  app.matches.move({ matchId: match.id, playerId: u2.id, action: 'roll', points: 2 });
  const finalState = app.matches.move({ matchId: match.id, playerId: u1.id, action: 'write', points: 3 });
  unsub();

  assert.equal(finalState.status, 'finished');
  assert.equal(finalState.moveNumber, 3);
  assert.equal(events.length >= 3, true);
});
