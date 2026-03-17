/**
 * Назначение файла: проверить security-требования Prompt D для API-ядра.
 * Роль в проекте: зафиксировать поведение rate-limit, идемпотентности ходов и anti-cheat ограничений по очередности.
 * Основные функции: тесты 409 на повторный moveId, 403 на ход не в свой ход, 429 для login/move лимитов.
 * Связи с другими файлами: использует services/api/src/app.mjs и его HttpError-коды.
 * Важно при изменении: сохранять явную проверку статус-кодов как критерий приёмки.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { createApiApp } from '../src/app.mjs';

const setupTwoUsersMatch = (config = {}) => {
  const app = createApiApp({ config: { DEFAULT_LANG: 'ru', ...config } });
  const u1 = app.auth.register({ email: 'sec_u1@test.dev', password: 'secret01' });
  const u2 = app.auth.register({ email: 'sec_u2@test.dev', password: 'secret02' });
  const match = app.matches.create({ gameId: 'tile_placement_demo', players: [u1.id, u2.id] });
  return { app, u1, u2, match };
};

test('повторный запрос с тем же moveId возвращает 409', () => {
  const { app, u1, match } = setupTwoUsersMatch();
  app.matches.move({ matchId: match.id, playerId: u1.id, action: 'place', moveId: 'm-1' });

  assert.throws(
    () => app.matches.move({ matchId: match.id, playerId: u1.id, action: 'pass', moveId: 'm-1' }),
    (error) => error.status === 409 && error.code === 'MOVE_ID_ALREADY_PROCESSED'
  );
});

test('попытка хода не в свой ход возвращает 403', () => {
  const { app, u2, match } = setupTwoUsersMatch();

  assert.throws(
    () => app.matches.move({ matchId: match.id, playerId: u2.id, action: 'place', moveId: 'm-2' }),
    (error) => error.status === 403 && error.code === 'NOT_YOUR_TURN'
  );
});

test('rate-limit работает на /auth/login эквиваленте', () => {
  const app = createApiApp({ config: { RATE_LIMIT_LOGIN: 2 } });
  app.auth.register({ email: 'rate_login@test.dev', password: 'secret01' });

  app.auth.login({ email: 'rate_login@test.dev', password: 'secret01', ip: '1.1.1.1' });
  app.auth.login({ email: 'rate_login@test.dev', password: 'secret01', ip: '1.1.1.1' });

  assert.throws(
    () => app.auth.login({ email: 'rate_login@test.dev', password: 'secret01', ip: '1.1.1.1' }),
    (error) => error.status === 429 && error.code === 'RATE_LIMIT_EXCEEDED'
  );
});

test('rate-limit работает на /matches/{id}/move эквиваленте', () => {
  const { app, u1, u2, match } = setupTwoUsersMatch({ RATE_LIMIT_MOVE: 1 });

  app.matches.move({ matchId: match.id, playerId: u1.id, action: 'place', moveId: 'move-1' });
  app.matches.move({ matchId: match.id, playerId: u2.id, action: 'place', moveId: 'move-2' });

  assert.throws(
    () => app.matches.move({ matchId: match.id, playerId: u1.id, action: 'place', moveId: 'move-3' }),
    (error) => error.status === 429 && error.code === 'RATE_LIMIT_EXCEEDED'
  );
});
