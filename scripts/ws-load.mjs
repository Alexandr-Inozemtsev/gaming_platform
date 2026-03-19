/**
 * Назначение файла: выполнить упрощённый load-тест realtime-слоя для локальной оценки ёмкости MVP.
 * Роль в проекте: дать быстрый инженерный сигнал по нагрузке на room events без внешних инструментов.
 * Основные функции: симуляция TARGET_WS_CONN подключений и TARGET_MOVE_RPS событий в минутном окне.
 * Связи с другими файлами: использует services/realtime/src/gateway.mjs и запускается из npm-скрипта.
 * Важно при изменении: это synthetic-тест EventEmitter-уровня, а не полноценный сетевой benchmark WebSocket.
 */

import { createRealtimeGateway } from '../services/realtime/src/gateway.mjs';

const TARGET_WS_CONN = Number(process.env.TARGET_WS_CONN ?? 200);
const TARGET_MOVE_RPS = Number(process.env.TARGET_MOVE_RPS ?? 20);
const TEST_DURATION_SEC = Number(process.env.LOAD_TEST_DURATION_SEC ?? 5);

const gateway = createRealtimeGateway();
const roomId = 'load_room';

for (let i = 0; i < TARGET_WS_CONN; i += 1) {
  const userId = `u_${i}`;
  gateway.connectUser(userId);
  gateway.joinRoom(userId, roomId, { videoPolicy: 'global' });
}

const totalEventsTarget = TARGET_MOVE_RPS * TEST_DURATION_SEC;
const start = Date.now();
for (let i = 0; i < totalEventsTarget; i += 1) {
  gateway.emitRoomEvent(roomId, 'match.move.applied', { idx: i, ts: Date.now() });
}
const elapsedMs = Date.now() - start;

const achievedRps = elapsedMs > 0 ? Number((totalEventsTarget / (elapsedMs / 1000)).toFixed(2)) : totalEventsTarget;
const snapshot = gateway.snapshot();

console.log(
  JSON.stringify(
    {
      mode: 'synthetic-event-bus',
      targetWsConn: TARGET_WS_CONN,
      targetMoveRps: TARGET_MOVE_RPS,
      durationSec: TEST_DURATION_SEC,
      totalEventsTarget,
      elapsedMs,
      achievedRps,
      onlineUsers: snapshot.onlineUsers.length,
      roomMembers: snapshot.rooms[roomId]?.length ?? 0
    },
    null,
    2
  )
);

if ((snapshot.rooms[roomId]?.length ?? 0) !== TARGET_WS_CONN) {
  console.error('LOAD_TEST_FAILED: room members count mismatch');
  process.exit(1);
}
