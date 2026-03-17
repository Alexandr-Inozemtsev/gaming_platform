/**
 * Назначение файла: проверить базовые realtime-сценарии MVP gateway.
 * Роль в проекте: гарантировать корректность presence/rooms/chat-событий.
 * Основные функции: подключение пользователя, вступление в комнату, отправка чата.
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
