/**
 * Назначение файла: реализовать минимальную in-memory админ-панель MVP.
 * Роль в проекте: предоставить операции login(admin), просмотр репортов, бан и мут пользователей.
 * Основные функции: проверка admin-логина, чтение таблицы репортов, применение санкций.
 * Связи с другими файлами: подключается к данным API через переданные зависимости.
 * Важно при изменении: не хранить реальные секреты и не усложнять контракт админ-функций.
 */

<<<<<<< codex/create-monorepo-for-tabletopplatform-sv1z0u
export const createAdminPanel = ({ moderationApi, analyticsApi, adminPassword = 'local_admin_password' }) => ({
=======
export const createAdminPanel = ({ moderationApi, adminPassword = 'local_admin_password' }) => ({
>>>>>>> main
  login: ({ username, password }) => {
    if (username !== 'admin' || password !== adminPassword) throw new Error('INVALID_ADMIN_CREDENTIALS');
    return { ok: true, role: 'admin' };
  },
  reportsTable: () => moderationApi.listReports(),
<<<<<<< codex/create-monorepo-for-tabletopplatform-sv1z0u
  analyticsEventsTable: ({ limit = 100 } = {}) => analyticsApi?.list?.({ limit }) ?? [],
  analyticsDashboard: () => analyticsApi?.dashboard?.() ?? { matches7d: 0, dauProxy: [] },
=======
>>>>>>> main
  ban: ({ userId, reason }) => moderationApi.ban({ userId, reason }),
  mute: ({ userId, reason }) => moderationApi.mute({ userId, reason })
});
