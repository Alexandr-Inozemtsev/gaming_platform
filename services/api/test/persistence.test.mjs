/**
 * Назначение файла: проверить сохранение/восстановление матчей после перезапуска API приложения.
 * Роль в проекте: покрыть acceptance-критерий восстановления состояния матча.
 * Основные функции: создать матч, сделать ход, пересоздать app с тем же store-файлом и проверить state.
 * Связи с другими файлами: использует services/api/src/app.mjs и файловое хранилище MATCH_STORE_FILE.
 * Важно при изменении: очищать временный файл, чтобы тест был изолирован и воспроизводим.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import fs from 'node:fs';
import path from 'node:path';
import { createApiApp } from '../src/app.mjs';

test('восстановление состояния матча после перезапуска', () => {
  const storeFile = path.join(process.cwd(), '.tmp', `matches_${Date.now()}.json`);

  const app1 = createApiApp({ config: { MATCH_STORE_FILE: storeFile } });
  const u1 = app1.auth.register({ email: 'p1@test.dev', password: 'secret01' });
  const u2 = app1.auth.register({ email: 'p2@test.dev', password: 'secret02' });
  const match = app1.matches.create({ gameId: 'tile_placement_demo', players: [u1.id, u2.id] });
  app1.matches.move({ matchId: match.id, playerId: u1.id, action: 'place', moveId: 'p-m1', payload: { row: 0, col: 0 } });

  const app2 = createApiApp({ config: { MATCH_STORE_FILE: storeFile } });
  const restored = app2.matches.getById(match.id);
  assert.equal(restored?.moveNumber, 1);
  assert.equal(restored?.gameState.grid[0][0].owner, u1.id);

  fs.rmSync(path.dirname(storeFile), { recursive: true, force: true });
});
