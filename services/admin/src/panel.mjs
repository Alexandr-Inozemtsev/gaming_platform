/**
 * Назначение файла: реализовать минимальную in-memory админ-панель MVP.
 * Роль в проекте: предоставить операции login(admin), просмотр репортов, бан и мут пользователей.
 * Основные функции: проверка admin-логина, чтение таблицы репортов, применение санкций.
 * Связи с другими файлами: подключается к данным API через переданные зависимости.
 * Важно при изменении: не хранить реальные секреты и не усложнять контракт админ-функций.
 */

export const createAdminPanel = ({ moderationApi, analyticsApi, adminPassword = 'local_admin_password' }) => ({
  login: ({ username, password }) => {
    if (username !== 'admin' || password !== adminPassword) throw new Error('INVALID_ADMIN_CREDENTIALS');
    return { ok: true, role: 'admin' };
  },
  reportsTable: () => moderationApi.listReports(),
  moderationQueue: () => moderationApi.listCases?.() ?? [],
  moderationCase: ({ caseId }) => moderationApi.getCaseById?.({ caseId }) ?? null,
  setCaseStatus: ({ caseId, status, moderatorUserId = 'admin' }) => moderationApi.updateCaseStatus?.({ caseId, status, moderatorUserId }),
  analyticsEventsTable: ({ limit = 100 } = {}) => analyticsApi?.list?.({ limit }) ?? [],
  analyticsDashboard: () => analyticsApi?.dashboard?.() ?? { matches7d: 0, dauProxy: [] },
  ban: ({ userId, reason, duration = '24h', moderatorUserId = 'admin', caseId = null }) =>
    moderationApi.ban({ userId, reason, duration, moderatorUserId, caseId }),
  mute: ({ userId, reason, duration = '1h', moderatorUserId = 'admin', caseId = null }) =>
    moderationApi.mute({ userId, reason, duration, moderatorUserId, caseId }),
  unban: ({ userId, reason = 'manual_review', moderatorUserId = 'admin', caseId = null }) =>
    moderationApi.unban({ userId, reason, moderatorUserId, caseId }),
  auditLog: () => moderationApi.auditLog?.() ?? []
});
