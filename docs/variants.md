# Редактор вариантов правил v0 (Prompt H)

## Назначение
Документ описывает минимальный редактор вариантов правил для существующих игр (`tile_placement_demo`, `roll_and_write_demo`) без пользовательского создания новых игр.

## Backend
Добавлены in-memory сущности `gameVariants` со статусами `draft` и `published`.

### Endpoint'ы
- `GET /games/{id}/variants?userId=...` — список вариантов для игры (опубликованные + свои черновики).
- `GET /variants?userId=...` — список моих вариантов.
- `POST /variants` — создать draft.
- `PUT /variants/{id}` — обновить draft.
- `POST /variants/{id}/validate` — проверить вариант.
- `POST /variants/{id}/publish` — публикация и выдача private link.
- `GET /join-variant/{token}` — разрешение private link в опубликованный вариант.

### Валидация
Проверяются `boardSize`, `winCondition`, `scoringMultipliers`, `turnTimer`.
Публикация блокируется при ошибках `validate`.

### Влияние варианта на матч
При `POST /matches` можно передать `variantId`.
Для опубликованного варианта изменяются:
- `gameState.size`;
- размер поля (`grid`/`sheet`);
- `maxMoves = boardSize * boardSize`.

## Mobile
Во вкладке **Create** добавлены:
- список моих вариантов;
- форма создания draft;
- кнопки `Validate`, `Test-play`, `Publish`;
- поле входа по private link (`join variant match`).

## Ограничения v0
- Хранение in-memory (без БД);
- private link имеет локальный формат `/join-variant/{token}`;
- в `scoringMultipliers` поддержан базовый словарь множителей без расширенной схемы.
