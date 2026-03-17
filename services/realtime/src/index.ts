/**
 * Назначение файла: сохранить TypeScript entrypoint для realtime-сервиса.
 * Роль в проекте: документировать зоны ответственности realtime слоя (presence/rooms/chat/match events).
 * Основные функции: задавать типы категорий событий для дальнейшей типизации WebSocket gateway.
 * Связи с другими файлами: runtime-реализация находится в services/realtime/src/gateway.mjs.
 * Важно при изменении: поддерживать соответствие между типами и фактическими event name.
 */

export type RealtimeEventType = 'presence' | 'rooms' | 'chat' | 'match_state';
