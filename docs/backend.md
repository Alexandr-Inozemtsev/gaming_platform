# Backend MVP: API, Realtime, Rules Engine, Admin

## Назначение
Документ фиксирует текущее backend-ядро MVP и объясняет, как связаны сервисы между собой.

## Сервисы
- `services/api` — HTTP API с endpoint'ами авторизации, каталога, матчей, магазина, репортов и админ-действий.
- `services/realtime` — событийный gateway (presence, rooms, chat, match state).
- `services/rules-engine` — детерминированные функции правил игры.
- `services/admin` — минимальная админ-панель (login, reports, ban/mute).

## Repository layer (этап миграции)
- В `services/api` начата миграция с прямого доступа к `state.*` на in-memory repositories.
- Текущий шаг покрывает базовые операции пользователей и матчей (`users`, `matches`) через адаптер `services/api/src/repositories/in-memory.mjs`.
- Цель следующего шага — расширить подход на санкции, аналитику и инвентарь, чтобы упростить переход на PostgreSQL/Redis.

## Конфигурация (шаблоны)
Секреты не храним в репозитории. Для локальной разработки задайте в `.env`:
- `JWT_SECRET=<локально сгенерированная строка>`
- `SESSION_TTL_MIN=30`
- `REFRESH_TTL_DAYS=30`
- `MATCH_STATE_SNAPSHOT_EVERY_N_MOVES=1`
- `DEFAULT_LANG=ru`

## Минимальные endpoint'ы API
- `POST /auth/register`
- `POST /auth/login`
- `POST /auth/refresh`
- `POST /auth/logoutAll`
- `GET /games`
- `GET /games/{id}`
- `POST /matches`
- `GET /matches`
- `GET /matches/{id}`
- `POST /matches/{id}/move`
- `POST /store/purchase-sandbox`
- `GET /inventory`
- `POST /reports`
- `POST /admin/ban`
- `POST /admin/mute`

## Интеграционный сценарий MVP
1. Зарегистрировать двух пользователей.
2. Создать матч.
3. Выполнить 3 хода.
4. Убедиться, что матч перешёл в `finished`.

Этот сценарий автоматизирован тестом `services/api/test/integration.test.mjs`.

## UI-заметка Prompt C
Минимальный макет комнаты игры:

```text
[GAME ROOM] Board | Action bar | Log | Chat
```

Токены для следующего шага фронтенда:
- `shadow.card=soft`
- `typography.h1=22`
- `typography.body=14`

## Security-обновления (Prompt D)
- Access/Refresh/logoutAll поддерживаются в auth-слое.
- Включена строгая DTO-валидация на входах API-операций.
- Добавлена идемпотентность ходов по `moveId`.
- Добавлен rate-limit для login и move.
- Включён server-authoritative RNG (клиентские очки игнорируются).
- Ведутся security-логи подозрительных действий.


## Moderation tools (Prompt N)
- Репорт из Game Room создаёт `report` и `case` со статусом `open`.
- Админка получает очередь кейсов и может менять статусы `open/in_review/closed`.
- Поддержаны `mute`, `ban`, `unban` и аудит действий модератора.
- Активный ban блокирует login и действия в матчах.
