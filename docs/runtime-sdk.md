# Runtime SDK Contract v1

Документ описывает первый контракт для бесшовного запуска игровых runtime внутри платформы.

## Цели v1
- Унифицировать обмен событиями между платформой и игровым runtime.
- Дать строгий формат payload для аналитики runtime-событий.
- Подготовить почву для embedded Unity flow (PoC на следующем шаге).

## Версионирование
- Текущая версия схемы: `runtime-sdk/v1`.
- Любой breaking change должен создавать новую версию (`runtime-sdk/v2`, ...).

## Схемы JSON Schema
- `contracts/runtime-sdk/v1/schemas/runtime-session-init.schema.json`
- `contracts/runtime-sdk/v1/schemas/runtime-event-envelope.schema.json`

## Runtime events (v1)
- `runtime.session.started`
- `runtime.session.paused`
- `runtime.session.resumed`
- `runtime.session.ended`
- `runtime.player.input`
- `runtime.move.requested`
- `runtime.move.applied`
- `runtime.move.rejected`
- `runtime.error`

## Минимальный envelope
```json
{
  "schemaVersion": "runtime-sdk/v1",
  "eventName": "runtime.move.applied",
  "sessionId": "sess_abc123",
  "matchId": "match_42",
  "runtime": {
    "engine": "unity",
    "engineVersion": "2022.3.54f1",
    "platform": "android"
  },
  "payload": {
    "moveId": "m_001"
  },
  "ts": "2026-04-01T10:30:00.000Z"
}
```

## API validation hooks
В `services/api/src/app.mjs` добавлена проверка:
1. `eventName` должен входить в белый список `ANALYTICS_ALLOWED_EVENTS`.
2. Для `runtime.*` событий payload обязан соответствовать runtime-контракту v1:
   - `schemaVersion=runtime-sdk/v1`
   - валидный `sessionId`
   - валидный `matchId`
   - объект `runtime` с поддерживаемым `engine`
   - валидный `ts`

Текущая реализация validation hooks находится в `services/api/src/runtime-sdk/contracts.mjs`.

## Примечание по Unity WebGL build path
Локальный путь вида `C:\unity_builds\big_walker_webgl` не должен коммититься в репозиторий как бинарный build-артефакт.
Рекомендуемый подход:
1. build хранится вне git;
2. runtime раздаётся через локальный/стейджинг static-host (CDN/nginx);
3. в приложение передаётся URL runtime через конфиг/переменные окружения.
