/**
 * Назначение файла: выполнить smoke-проверки ключевых API операций и bot flow.
 * Роль в проекте: быстро подтвердить, что auth/catalog/store/matches работают вместе после изменений.
 * Основные функции: register/login, games list, create bot room, sandbox purchase.
 * Связи с другими файлами: проверяет services/api/src/app.mjs.
 * Важно при изменении: тест должен оставаться коротким и устойчивым к несущественным refactor-изменениям.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { createApiApp } from '../src/app.mjs';

test('smoke API + bot матч', () => {
  const app = createApiApp({ config: { DEFAULT_LANG: 'ru' } });
  const user = app.auth.register({ email: 'smoke@test.dev', password: 'secret01' });
  const login = app.auth.login({ email: 'smoke@test.dev', password: 'secret01' });
  const games = app.catalog.listGames();
  const match = app.matches.create({ gameId: 'tile_placement_demo', players: [user.id, `${user.id}_bot`], botLevel: 'easy' });
  const moved = app.matches.move({ matchId: match.id, playerId: user.id, action: 'place', moveId: 'smoke-1', payload: { row: 0, col: 0 } });

  assert.equal(Boolean(login.accessToken), true);
  assert.equal(games.length >= 2, true);
  assert.equal(app.store.purchaseSandbox({ userId: user.id, sku: 'skin_001' }).ok, true);
  assert.equal(moved.moveNumber >= 1, true);
});
