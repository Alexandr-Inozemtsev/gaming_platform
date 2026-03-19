# Testing контур MVP (Prompt K)

## Назначение
Документ фиксирует тестовую стратегию MVP: unit, integration, e2e smoke и упрощённый load.

## CI pipeline
ASCII-поток:
`lint -> unit -> integration -> e2e`

## 1) Unit tests (rules-engine)
Файл: `services/rules-engine/test/index.test.mjs`.

Добавлены property-тесты (инварианты):
- tile: число занятых клеток не убывает и растёт максимум на 1 за ход;
- roll-and-write: число отмеченных клеток у каждого игрока не убывает.

## 2) Integration tests (API)
Файл: `services/api/test/integration.test.mjs`.

Сценарии:
- `create match -> moves -> finish`;
- отдельный forced-finish сценарий через `maxMoves`.

## 3) E2E smoke (Flutter)
Файл: `apps/mobile/test/smoke_test.dart`.

Минимальный путь:
- открыть shell,
- перейти в Catalog,
- открыть Room.
- Переходы выполняются по иконкам, чтобы тест не зависел от RU/EN локали.

## 4) Load test (упрощённый)
Файл: `scripts/ws-load.mjs`.

- Симуляция `TARGET_WS_CONN` пользователей.
- Симуляция `TARGET_MOVE_RPS` событий `match.move.applied`.
- Результат печатается в JSON.
- Время измеряется через `process.hrtime.bigint()` для корректного расчёта даже на очень быстрых прогонах.

### Параметры
- `TARGET_WS_CONN=200`
- `TARGET_MOVE_RPS=20`
- `LOAD_TEST_DURATION_SEC=5` (по умолчанию)

### Ограничение
Тест synthetic: проверяет EventEmitter-слой gateway, а не реальные TCP/WebSocket соединения.

## Команды
- `npm run lint`
- `npm test`
- `npm run test:load:ws`
- `flutter test test/smoke_test.dart`
- `flutter analyze`

## Токены QA
- `qa.pass = #4EE59A`
- `qa.fail = #FF5C7A`
