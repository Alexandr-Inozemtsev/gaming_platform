/**
 * Назначение файла: проверить минимальные операции admin-панели MVP.
 * Роль в проекте: гарантировать доступ к таблице репортов и санкциям (ban/mute).
 * Основные функции: login(admin), reportsTable(), ban(), mute().
 * Связи с другими файлами: проверяет services/admin/src/panel.mjs и moderation API.
 * Важно при изменении: держать тесты простыми и независимыми от внешней инфраструктуры.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { createAdminPanel } from '../src/panel.mjs';

test('admin login успешен с корректными данными', () => {
  const moderationApi = {
    listReports: () => [],
    ban: ({ userId }) => ({ action: 'ban', userId }),
    mute: ({ userId }) => ({ action: 'mute', userId })
  };
  const admin = createAdminPanel({ moderationApi, adminPassword: 'secret' });
  assert.equal(admin.login({ username: 'admin', password: 'secret' }).ok, true);
});

test('admin видит репорты и применяет ban/mute', () => {
  const moderationApi = {
    listReports: () => [{ id: 'r1' }],
    ban: ({ userId }) => ({ action: 'ban', userId }),
    mute: ({ userId }) => ({ action: 'mute', userId })
  };
  const admin = createAdminPanel({ moderationApi });
  assert.equal(admin.reportsTable().length, 1);
  assert.equal(admin.ban({ userId: 'u1', reason: 'tox' }).action, 'ban');
  assert.equal(admin.mute({ userId: 'u1', reason: 'spam' }).action, 'mute');
});
