# Internal Game Generator (Prompt L)

## Назначение
Внутренний инструмент команды (не для пользователей), который генерирует game definitions, симулирует игры ботами и подготавливает тестовые фикстуры.

## Важная пометка
`internal.note = "not user-facing"`

## Шаблоны
Поддерживаемые шаблоны:
- `tile`
- `rollwrite`
- `setcollection`
- `pushyourluck`

## Команда
```bash
npm run gen:game -- --template tile --out services/rules-engine/fixtures/ --n 120
```

Где:
- `--template` — шаблон генерации;
- `--out` — папка для JSON definition и fixture;
- `--n` — число симуляций (`N_SIM`, рекомендуемый диапазон 100..1000).

## Выход
Пример CLI output:
- `Generated: tile_v1.json OK`
- `Generated: tile_v1.fixture.json OK`

## Как работает симуляция
- Для `tile`/`rollwrite` используется текущий rules-engine (`applyMove`, `legalMoves`, `createInitialGameState`).
- Для `setcollection`/`pushyourluck` используется fallback-симуляция с гарантированным завершением по `maxMoves`.

## Интеграция с тестами
- Сгенерированная фикстура `services/rules-engine/fixtures/tile_v1.fixture.json` подключена в unit tests.
- Тест проверяет, что все симуляции завершены и статистика корректна.

## Ограничения
- Инструмент внутренний и не имеет пользовательского UI.
- Fallback-симуляции для неподдерживаемых движком шаблонов не претендуют на полноценную игровую модель.
