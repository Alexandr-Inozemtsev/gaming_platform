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
    listCases: () => [],
    getCaseById: () => null,
    updateCaseStatus: () => null,
    ban: ({ userId }) => ({ action: 'ban', userId }),
    mute: ({ userId }) => ({ action: 'mute', userId }),
    unban: ({ userId }) => ({ action: 'unban', userId }),
    auditLog: () => []
  };
  const admin = createAdminPanel({ moderationApi, adminPassword: 'secret' });
  assert.equal(admin.login({ username: 'admin', password: 'secret' }).ok, true);
});

test('admin видит репорты и применяет ban/mute', () => {
  const cases = [{ id: 'c1', status: 'open' }];
  const moderationApi = {
    listReports: () => [{ id: 'r1' }],
    listCases: () => cases,
    getCaseById: ({ caseId }) => cases.find((item) => item.id === caseId) ?? null,
    updateCaseStatus: ({ caseId, status }) => {
      const item = cases.find((entry) => entry.id === caseId);
      if (!item) return null;
      item.status = status;
      return item;
    },
    ban: ({ userId }) => ({ action: 'ban', userId }),
    mute: ({ userId }) => ({ action: 'mute', userId }),
    unban: ({ userId }) => ({ action: 'unban', userId }),
    auditLog: () => [{ id: 'a1', action: 'ban' }]
  };
  const analyticsApi = {
    list: () => [{ id: 'e1', eventName: 'login_success' }],
    dashboard: () => ({ matches7d: 3, dauProxy: [{ day: '2026-03-19', uniqueUsers: 2 }] })
  };
  const admin = createAdminPanel({ moderationApi, analyticsApi });
  assert.equal(admin.reportsTable().length, 1);
  assert.equal(admin.moderationQueue().length, 1);
  assert.equal(admin.moderationCase({ caseId: 'c1' })?.id, 'c1');
  assert.equal(admin.setCaseStatus({ caseId: 'c1', status: 'in_review' })?.status, 'in_review');
  assert.equal(admin.analyticsEventsTable().length, 1);
  assert.equal(admin.analyticsDashboard().matches7d, 3);
  assert.equal(admin.ban({ userId: 'u1', reason: 'tox' }).action, 'ban');
  assert.equal(admin.mute({ userId: 'u1', reason: 'spam' }).action, 'mute');
  assert.equal(admin.unban({ userId: 'u1' }).action, 'unban');
  assert.equal(admin.auditLog().length, 1);
});
