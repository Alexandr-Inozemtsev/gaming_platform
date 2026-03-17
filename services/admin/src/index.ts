/**
 * Назначение файла: сохранить TypeScript entrypoint для admin-сервиса.
 * Роль в проекте: документировать минимальные операции админки MVP.
 * Основные функции: задавать названия действий (login/reports/ban/mute) как контракт модуля.
 * Связи с другими файлами: runtime-реализация в services/admin/src/panel.mjs.
 * Важно при изменении: синхронизировать список действий с admin API и документацией.
 */

export type AdminAction = 'login' | 'reports_table' | 'ban' | 'mute';
