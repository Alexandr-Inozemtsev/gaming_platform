# Модерация MVP (Prompt N)

## Назначение
Документ описывает модерационный контур MVP: репорты, очередь кейсов, санкции mute/ban/unban и аудит действий модераторов.

## Что поддерживается
- Отправка репорта из Game Room (`source=game_room`) по целям:
  - `chat`
  - `profile`
  - `variant` (только если `EDITOR_ENABLED=true`)
- Кейсы модерации со статусами:
  - `open`
  - `in_review`
  - `closed`
- Действия модератора:
  - `mute`
  - `ban`
  - `unban`
- Аудит действий модераторов (`/admin/moderation/audit`).

## Политики
- Длительности бана/мута (`BAN_DURATIONS`): `1h`, `24h`, `7d`, `permanent`.
- Типы политик (`DEFAULT_POLICY`):
  - `no negotiation`
  - `bluff`
  - `party`
  - `physical`

## API-контракты
### Пользовательские
- `POST /reports`

### Админские
- `GET /admin/reports`
- `GET /admin/cases?status=open|in_review|closed`
- `GET /admin/cases/{caseId}`
- `POST /admin/cases/{caseId}/status`
- `POST /admin/ban`
- `POST /admin/mute`
- `POST /admin/unban`
- `GET /admin/moderation/audit`
- `GET /admin/moderation/policies`

## Ограничения доступа
- Пользователь с активным `ban` не может:
  - войти в систему (`/auth/login` -> `403 USER_BANNED`)
  - создавать/играть матчи (операции матчей возвращают `403 USER_BANNED`).

## UI-токены
- `mod.caseOpen=#FFD166`
- `mod.caseClosed=#4EE59A`
