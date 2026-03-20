# Analytics MVP (Prompt J)

## Назначение
Документ описывает базовую аналитику, логирование запросов и технические метрики для MVP.

## События продукта
Поддерживаемые event names:
- `onboarding_complete`
- `login_success`
- `match_create`
- `match_move`
- `match_finish`
- `store_view`
- `purchase_attempt`
- `purchase_success`
- `variant_publish`
- `report_sent`

## Технические метрики
- `latency_move` (как событие с `payload.latencyMs`)
- `reconnect_count`
- `ws_disconnects`
- `video_connect_failures`

## Backend
- Добавлен middleware-style logging запросов в `services/api/src/server.mjs`:
  - метод,
  - путь,
  - длительность,
  - timestamp.
- `LOG_LEVEL=debug` включает debug-вывод в консоль.
- API endpoint'ы:
  - `POST /analytics/events`
  - `GET /analytics/events?limit=...&eventName=...`
  - `POST /analytics/metrics`
  - `GET /admin/analytics/dashboard`

## Клиент
- Добавлен `AnalyticsClient` с batching и периодическим flush.
- События отправляются из AppState при ключевых действиях.

## Admin (заглушка)
- Таблица событий (последние записи) и dashboard-заглушка:
  - `7-day matches`
  - `DAU proxy` (уникальные users/day).

## Инфраструктура
- В `infra/init.sql` добавлена таблица `platform.analytics_events` и индексы.
- На текущем этапе runtime использует in-memory коллекцию в API; SQL-таблица подготовлена для следующего шага интеграции с Postgres.

## Переменные окружения
- `ANALYTICS_PROVIDER` (self-hosted/SaaS)
- `LOG_LEVEL` (`info`/`debug`)
