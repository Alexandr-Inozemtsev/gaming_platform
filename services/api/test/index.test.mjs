/**
 * Назначение файла: выполнить базовые smoke-тесты API-модулей MVP.
 * Роль в проекте: проверить, что ключевые операции auth/catalog/store/moderation доступны через app-слой.
 * Основные функции: register/login/catalog/store/report/admin action.
 * Связи с другими файлами: проверяет services/api/src/app.mjs.
 * Важно при изменении: оставлять тест небольшим, а сложные сценарии переносить в integration/security тесты.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { createApiApp } from '../src/app.mjs';

test('smoke API операций', () => {
  const app = createApiApp({ config: { DEFAULT_LANG: 'ru' } });
  const user = app.auth.register({ email: 'smoke@test.dev', password: 'secret01' });
  const login = app.auth.login({ email: 'smoke@test.dev', password: 'secret01' });

  assert.equal(Boolean(login.accessToken), true);
  assert.equal(app.catalog.listGames().length >= 2, true);
  assert.equal(app.store.purchaseSandbox({ userId: user.id, sku: 'skin_001' }).ok, true);
  assert.equal(
    app.moderation.report({ reporterUserId: user.id, targetType: 'chat', targetId: 'm1', reason: 'spam' }).id.startsWith('report_'),
    true
  );
  assert.equal(app.moderation.ban({ userId: user.id, reason: 'abuse' }).action, 'ban');
});
