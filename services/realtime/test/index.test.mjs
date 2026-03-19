/**
 * Назначение файла: проверить базовые realtime-сценарии MVP gateway, включая signaling для WebRTC.
 * Роль в проекте: гарантировать корректность presence/rooms/chat/video-событий и правил invite_only.
 * Основные функции: подключение пользователя, вступление в комнату, отправка чата, relay SDP/ICE и rate limiting signaling.
 * Связи с другими файлами: проверяет services/realtime/src/gateway.mjs.
 * Важно при изменении: не ломать формат событий room:{id}.
 */

import test from 'node:test';
import assert from 'node:assert/strict';
import { createRealtimeGateway } from '../src/gateway.mjs';

test('gateway хранит presence и комнаты', () => {
  const gw = createRealtimeGateway();
  gw.connectUser('u1');
  gw.joinRoom('u1', 'r1');
  const snap = gw.snapshot();
  assert.deepEqual(snap.onlineUsers, ['u1']);
  assert.deepEqual(snap.rooms.r1, ['u1']);
});

test('gateway публикует chat event в комнату', async () => {
  const gw = createRealtimeGateway();
  await new Promise((resolve) => {
    const off = gw.onRoomEvent('r1', (event) => {
      assert.equal(event.type, 'chat.message');
      off();
      resolve();
    });
    gw.sendChat('r1', { from: 'u1', text: 'privet' });
  });
});

test('gateway публикует video.offer только для участника приватной комнаты', async () => {
  const gw = createRealtimeGateway();
  gw.configurePrivateRoom('r2', ['u1', 'u2']);
  gw.joinRoom('u1', 'r2', { videoPolicy: 'invite_only' });
  gw.joinRoom('u2', 'r2', { videoPolicy: 'invite_only' });
  await new Promise((resolve) => {
    const off = gw.onRoomEvent('r2', (event) => {
      assert.equal(event.type, 'video.offer');
      assert.equal(event.payload.fromUserId, 'u1');
      off();
      resolve();
    });
    gw.relayVideoSignal({
      roomId: 'r2',
      userId: 'u1',
      targetUserId: 'u2',
      type: 'video.offer',
      payload: { sdp: 'fake-sdp' }
    });
  });
});

test('gateway блокирует signaling для неинвайченного пользователя', () => {
  const gw = createRealtimeGateway();
  gw.configurePrivateRoom('r3', ['u1']);
  assert.throws(() => gw.joinRoom('uX', 'r3', { videoPolicy: 'invite_only' }), /ROOM_INVITE_REQUIRED/);
});
