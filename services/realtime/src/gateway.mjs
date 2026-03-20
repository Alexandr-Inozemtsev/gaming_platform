/**
 * Назначение файла: реализовать MVP realtime gateway для presence, rooms, chat, событий матча и signaling WebRTC.
 * Роль в проекте: дать API и клиенту единый канал событий без привязки к конкретному WebSocket-фреймворку.
 * Основные функции: join/leave присутствия, приватные комнаты invite_only, chat, signaling SDP/ICE и rate limiting signaling.
 * Связи с другими файлами: используется services/api/src/app.mjs для match events и apps/mobile/lib/services/ws_client.dart для клиентских событий.
 * Важно при изменении: не ломать формат событий и всегда проверять membership/invite для video.offer/video.answer/video.iceCandidate.
 */

import { EventEmitter } from 'node:events';

export const createRealtimeGateway = () => {
  const bus = new EventEmitter();
  const presence = new Set();
  const rooms = new Map();
  const invitedRooms = new Map();
  const signalingBuckets = new Map();

  const SIGNALING_LIMIT = 40;
  const SIGNALING_WINDOW_MS = 60_000;

  const ensureRoom = (roomId) => {
    if (!rooms.has(roomId)) rooms.set(roomId, new Set());
    return rooms.get(roomId);
  };

  const checkSignalingRate = (roomId, userId) => {
    const key = `${roomId}:${userId}`;
    const now = Date.now();
    const current = signalingBuckets.get(key) ?? { count: 0, resetAt: now + SIGNALING_WINDOW_MS };
    if (now > current.resetAt) {
      current.count = 0;
      current.resetAt = now + SIGNALING_WINDOW_MS;
    }
    current.count += 1;
    signalingBuckets.set(key, current);
    if (current.count > SIGNALING_LIMIT) throw new Error('SIGNALING_RATE_LIMIT_EXCEEDED');
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
    configurePrivateRoom: (roomId, invitedUserIds) => {
      invitedRooms.set(roomId, new Set(invitedUserIds));
    },
    joinRoom: (userId, roomId, { videoPolicy = 'invite_only' } = {}) => {
      if (videoPolicy === 'invite_only') {
        const invited = invitedRooms.get(roomId);
        if (invited && !invited.has(userId)) throw new Error('ROOM_INVITE_REQUIRED');
      }
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
    relayVideoSignal: ({ roomId, userId, targetUserId, type, payload, videoPolicy = 'invite_only' }) => {
      const allowedEvents = new Set(['video.offer', 'video.answer', 'video.iceCandidate']);
      if (!allowedEvents.has(type)) throw new Error('VIDEO_SIGNAL_UNSUPPORTED');
      const members = ensureRoom(roomId);
      if (!members.has(userId)) throw new Error('ROOM_MEMBERSHIP_REQUIRED');
      if (videoPolicy === 'invite_only') {
        const invited = invitedRooms.get(roomId);
        if (invited && (!invited.has(userId) || (targetUserId && !invited.has(targetUserId)))) throw new Error('ROOM_INVITE_REQUIRED');
      }
      checkSignalingRate(roomId, userId);
      const event = { roomId, type, payload: { fromUserId: userId, targetUserId, ...payload } };
      bus.emit(`room:${roomId}`, event);
      return event;
    },
    onRoomEvent: (roomId, listener) => {
      bus.on(`room:${roomId}`, listener);
      return () => bus.off(`room:${roomId}`, listener);
    },
    snapshot: () => ({
      onlineUsers: [...presence],
      rooms: Object.fromEntries([...rooms.entries()].map(([k, v]) => [k, [...v]])),
      invitedRooms: Object.fromEntries([...invitedRooms.entries()].map(([k, v]) => [k, [...v]]))
    })
  };
};
