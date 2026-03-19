/**
 * Назначение файла: проверить, что HTTP-слой API корректно маппит security-ошибки в нужные статус-коды.
 * Роль в проекте: обеспечить выполнение acceptance-критериев Prompt D именно на уровне endpoint-ответов.
 * Основные функции: тесты 403 и 409 через createHttpHandler без запуска реального TCP-сервера.
 * Связи с другими файлами: использует services/api/src/server.mjs.
 * Важно при изменении: сохранять проверки статусов 403/409 как контракт внешнего API.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { EventEmitter } from 'node:events';
import { createHttpHandler } from '../src/server.mjs';

const invoke = async ({ handler, method, path, body }) => {
  const req = new EventEmitter();
  req.method = method;
  req.url = path;
  req.headers = {};
  req.socket = { remoteAddress: '127.0.0.1' };
  req[Symbol.asyncIterator] = async function* () {
    if (body) yield Buffer.from(JSON.stringify(body));
  };

  let status = 0;
  let payload = '';
  const res = {
    writeHead: (s) => {
      status = s;
    },
    end: (chunk) => {
      payload = chunk;
    }
  };

  await handler(req, res);
  return { status, json: JSON.parse(payload || '{}') };
};

test('HTTP: повторный moveId возвращает 409 Conflict', async () => {
  const handler = createHttpHandler();

  const r1 = await invoke({ handler, method: 'POST', path: '/auth/register', body: { email: 'h1@test.dev', password: 'secret01' } });
  const r2 = await invoke({ handler, method: 'POST', path: '/auth/register', body: { email: 'h2@test.dev', password: 'secret02' } });
  const match = await invoke({
    handler,
    method: 'POST',
    path: '/matches',
    body: { gameId: 'tile_placement_demo', players: [r1.json.id, r2.json.id] }
  });

  await invoke({
    handler,
    method: 'POST',
    path: `/matches/${match.json.id}/move`,
    body: { playerId: r1.json.id, action: 'place', moveId: 'dup-1', payload: { row: 0, col: 0 } }
  });

  const repeated = await invoke({
    handler,
    method: 'POST',
    path: `/matches/${match.json.id}/move`,
    body: { playerId: r2.json.id, action: 'place', moveId: 'dup-1', payload: { row: 0, col: 1 } }
  });

  assert.equal(repeated.status, 409);
});

test('HTTP: ход не в свой ход возвращает 403', async () => {
  const handler = createHttpHandler();

  const r1 = await invoke({ handler, method: 'POST', path: '/auth/register', body: { email: 'h3@test.dev', password: 'secret01' } });
  const r2 = await invoke({ handler, method: 'POST', path: '/auth/register', body: { email: 'h4@test.dev', password: 'secret02' } });
  const match = await invoke({
    handler,
    method: 'POST',
    path: '/matches',
    body: { gameId: 'tile_placement_demo', players: [r1.json.id, r2.json.id] }
  });

  const badMove = await invoke({
    handler,
    method: 'POST',
    path: `/matches/${match.json.id}/move`,
    body: { playerId: r2.json.id, action: 'place', moveId: 'wrong-turn-1', payload: { row: 0, col: 0 } }
  });

  assert.equal(badMove.status, 403);
});
