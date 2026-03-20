/**
 * Назначение файла: проверить MVP-контур модерации (репорты, кейсы, mute/ban/unban, аудит и ограничения для забаненного).
 * Роль в проекте: зафиксировать acceptance-контракты Prompt N и защитить их от регрессий.
 * Основные функции: тестирует создание репорта из game room, статусы кейса, бан по длительности, unban и запрет на игру.
 * Связи с другими файлами: использует services/api/src/app.mjs и косвенно маршруты server.mjs.
 * Важно при изменении: сохранять проверки кодов ошибок/статусов, так как это внешний контракт админки.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { createApiApp } from '../src/app.mjs';

const boot = () => {
  const app = createApiApp({ config: { DEFAULT_LANG: 'ru', EDITOR_ENABLED: 'true' } });
  const reporter = app.auth.register({ email: `rep_${Math.random()}@test.dev`, password: 'secret01' });
  const offender = app.auth.register({ email: `off_${Math.random()}@test.dev`, password: 'secret02' });
  return { app, reporter, offender };
};

test('репорт из game room формирует open-case в мод-очереди', () => {
  const { app, reporter } = boot();
  const result = app.moderation.report({
    reporterUserId: reporter.id,
    targetType: 'chat',
    targetId: 'room_1:msg_1',
    reason: 'Оскорбления в чате',
    source: 'game_room',
    policyType: 'bluff'
  });

  assert.equal(result.case.status, 'open');
  assert.equal(app.moderation.listCases().length, 1);
  assert.equal(app.moderation.listCases({ status: 'open' }).length, 1);
});

test('админ переводит кейс в in_review и применяет ban с аудитом', () => {
  const { app, reporter, offender } = boot();
  const reported = app.moderation.report({
    reporterUserId: reporter.id,
    targetType: 'profile',
    targetId: offender.id,
    reason: 'Токсичный ник',
    source: 'game_room',
    policyType: 'party'
  });

  const updatedCase = app.moderation.updateCaseStatus({ caseId: reported.case.id, status: 'in_review', moderatorUserId: 'mod_1' });
  assert.equal(updatedCase.status, 'in_review');

  const ban = app.moderation.ban({
    userId: offender.id,
    reason: 'Повторные нарушения',
    duration: '24h',
    moderatorUserId: 'mod_1',
    caseId: reported.case.id
  });

  assert.equal(ban.action, 'ban');
  assert.equal(Boolean(ban.expiresAt), true);
  assert.equal(app.moderation.getCaseById({ caseId: reported.case.id }).status, 'closed');
  assert.equal(app.moderation.auditLog().some((row) => row.action === 'ban'), true);
});

test('забаненный не может войти и играть, после unban снова может войти', () => {
  const { app, reporter, offender } = boot();
  app.moderation.ban({ userId: offender.id, reason: 'Спам', duration: 'permanent', moderatorUserId: 'mod_2' });

  assert.throws(
    () => app.auth.login({ email: offender.email, password: 'secret02', ip: '3.3.3.3' }),
    (error) => error.status === 403 && error.code === 'USER_BANNED'
  );

  const match = app.matches.create({ gameId: 'tile_placement_demo', players: [reporter.id, `${reporter.id}_bot`] });
  assert.throws(
    () => app.matches.move({ matchId: match.id, playerId: offender.id, action: 'place', moveId: 'm-bad', payload: { row: 0, col: 0 } }),
    (error) => error.status === 403 && error.code === 'USER_BANNED'
  );

  const unban = app.moderation.unban({ userId: offender.id, reason: 'Апелляция одобрена', moderatorUserId: 'mod_2' });
  assert.equal(unban.ok, true);
  const loginAfterUnban = app.auth.login({ email: offender.email, password: 'secret02', ip: '3.3.3.3' });
  assert.equal(Boolean(loginAfterUnban.accessToken), true);
});

test('повторный ban заменяет старый активный ban, unban снимает все активные bans', () => {
  const { app, offender } = boot();
  const first = app.moderation.ban({ userId: offender.id, reason: 'Первый бан', duration: '24h', moderatorUserId: 'mod_a' });
  const second = app.moderation.ban({ userId: offender.id, reason: 'Второй бан', duration: '7d', moderatorUserId: 'mod_b' });

  assert.equal(first.active, true);
  assert.equal(second.active, true);
  const activeBeforeUnban = app.state.sanctions.filter((row) => row.userId === offender.id && row.type === 'ban' && row.active);
  assert.equal(activeBeforeUnban.length, 1);

  app.moderation.unban({ userId: offender.id, reason: 'Снятие санкции', moderatorUserId: 'mod_c' });
  const activeAfterUnban = app.state.sanctions.filter((row) => row.userId === offender.id && row.type === 'ban' && row.active);
  assert.equal(activeAfterUnban.length, 0);
});

test('матч нельзя создать для несуществующего пользователя', () => {
  const app = createApiApp({ config: { DEFAULT_LANG: 'ru', EDITOR_ENABLED: 'true' } });
  const user = app.auth.register({ email: `u_${Math.random()}@test.dev`, password: 'secret01' });
  assert.throws(
    () => app.matches.create({ gameId: 'tile_placement_demo', players: [user.id, 'ghost_user'] }),
    (error) => error.status === 404 && error.code === 'USER_NOT_FOUND'
  );
});
