/**
 * Назначение файла: реализовать MVP realtime gateway для presence, rooms, chat и событий матча.
 * Роль в проекте: дать API и клиенту единый канал событий без привязки к конкретному WebSocket-фреймворку.
 * Основные функции: join/leave присутствия, подписка на комнаты, чат-сообщения, события состояния матча.
 * Связи с другими файлами: используется services/api/src/app.mjs для публикации match events.
 * Важно при изменении: не ломать формат событий, чтобы клиенты могли безопасно обрабатывать обновления.
 */

import { EventEmitter } from 'node:events';

export const createRealtimeGateway = () => {
  const bus = new EventEmitter();
  const presence = new Set();
  const rooms = new Map();

  const ensureRoom = (roomId) => {
    if (!rooms.has(roomId)) rooms.set(roomId, new Set());
    return rooms.get(roomId);
  };

  return {
    connectUser: (userId) => {
      presence.add(userId);
      bus.emit('presence.join', { userId });
    },
    disconnectUser: (userId) => {
      presence.delete(userId);
      bus.emit('presence.leave', { userId });
    },
    joinRoom: (userId, roomId) => {
      ensureRoom(roomId).add(userId);
      bus.emit('room.join', { userId, roomId });
    },
    leaveRoom: (userId, roomId) => {
      ensureRoom(roomId).delete(userId);
      bus.emit('room.leave', { userId, roomId });
    },
    sendChat: (roomId, payload) => {
      const event = { roomId, type: 'chat.message', payload };
      bus.emit(`room:${roomId}`, event);
      return event;
    },
    emitMatchState: (matchId, payload) => {
      const event = { roomId: matchId, type: 'match.state', payload };
      bus.emit(`room:${matchId}`, event);
      return event;
    },
    emitRoomEvent: (roomId, type, payload) => {
      const event = { roomId, type, payload };
      bus.emit(`room:${roomId}`, event);
      return event;
    },
    onRoomEvent: (roomId, listener) => {
      bus.on(`room:${roomId}`, listener);
      return () => bus.off(`room:${roomId}`, listener);
    },
    snapshot: () => ({
      onlineUsers: [...presence],
      rooms: Object.fromEntries([...rooms.entries()].map(([k, v]) => [k, [...v]]))
    })
  };
};
