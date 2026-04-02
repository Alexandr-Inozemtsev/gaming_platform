# TabletopPlatform Monorepo

Монорепозиторий MVP для цифровой платформы настольных игр.

## Параметры MVP
- **Название приложения:** `TabletopPlatform`
- **Режим региона:** `global` (допустимы `global` и `ru_by`)
- **Языки интерфейса:** `ru`, `en`
- **Игры MVP:** `big_walker_demo`, `tile_placement_demo`, `roll_and_write_demo`

## Структура репозитория
- `apps/mobile` — Flutter-клиент (каркас приложения)
- `services/api` — backend API (TypeScript-заглушка)
- `services/realtime` — realtime-шлюз (TypeScript-заглушка)
- `services/rules-engine` — библиотека игровых правил
- `libraries/games` — отдельная библиотека определений игр (каталог game-specific данных)
- `services/admin` — минимальный backend для админ-функций
- `infra` — Docker Compose, шаблоны переменных окружения, init.sql
- `docs` — архитектурная и операционная документация

## Требования к окружению
- Node.js 20+
- npm 10+
- Docker + Docker Compose
- Flutter SDK (для мобильной части)

## Быстрый старт
```bash
npm install
npm run lint
npm test
```

## Локальная инфраструктура
```bash
cd infra
cp .env.example .env
docker compose up -d
docker compose logs -f
```

Поднимаются сервисы:
- PostgreSQL на порту `5432`
- Redis на порту `6379`

Подробности: `docs/infra.md`.

## Deploy P2 (staging/prod)
См. `docs/deploy.md` для полного процесса. Коротко:

```bash
export ENV=staging
export DB_MIGRATE=true

docker build -f infra/Dockerfile --target api -t tabletop-api:${ENV} .
docker build -f infra/Dockerfile --target matches -t tabletop-matches:${ENV} .
docker build -f infra/Dockerfile --target campaigns -t tabletop-campaigns:${ENV} .
docker build -f infra/Dockerfile --target analytics -t tabletop-analytics:${ENV} .
docker build -f infra/Dockerfile --target web-socket -t tabletop-websocket:${ENV} .

if [ "${DB_MIGRATE}" = "true" ]; then
  npx prisma migrate deploy
fi

kubectl apply -f k8s/
```

One-command:

```bash
npm run prod-up
```

## Release checklist и one-button запуск (Prompt P)
Быстрый запуск локального контура:

```bash
npm install
scripts/dev-up.sh
```

Ручные команды (эквивалент):

```bash
# infra
cd infra && docker compose -f docker-compose.yml up -d

# backend runtime из корня репозитория
REGION_MODE=global API_PORT=3000 node services/api/src/runtime.mjs
REGION_MODE=global REALTIME_PORT=3001 node services/realtime/src/runtime.mjs
REGION_MODE=global ADMIN_PORT=3002 node services/admin/src/runtime.mjs
REGION_MODE=global RULES_ENGINE_PORT=3003 node services/rules-engine/src/runtime.mjs

# mobile
cd apps/mobile && flutter run -d emulator-5554
cd apps/mobile && flutter run -d "iPhone 15"
```

Smoke-проверка сценария:

```bash
scripts/smoke.sh
```

Остановка контура:

```bash
scripts/dev-down.sh
```

## Flutter (локально)
```bash
cd apps/mobile
flutter doctor
flutter pub get
flutter analyze
flutter run
```

Если шрифт `Inter` недоступен, допускается системный fallback.

## Инструменты монорепозитория
- Управление пакетами: `npm workspaces`
- `melos`: **не используется в базовой версии MVP (не указано)**
- CI: GitHub Actions (`.github/workflows/ci.yml`)

## Команды из корня
- `npm run lint` — минимальные проверки качества backend-пакетов
- `npm test` — unit-тесты всех backend-пакетов

## Backend MVP (Prompt C)
Подробности реализации backend-ядра: `docs/backend.md`.


## Security (Prompt D)
Подробности по безопасности MVP: `docs/security.md`.

## Moderation tools (Prompt N)
Подробности модерационного контура: `docs/moderation.md`.

## Mobile MVP
Подробности мобильного клиента: `docs/mobile.md`.

## Localization (Prompt O)
Подробности i18n RU/EN: `docs/i18n.md`.

## MVP Games
Описание правил и ботов: `docs/games.md`.

## Games library (выделение игровых файлов)
Все game-specific определения и ассеты выносятся в `libraries/games/` и подключаются из ядра платформы. Базовые definitions: `libraries/games/src/definitions.mjs`.

## Store MVP
Документация магазина и инвентаря: `docs/store.md`.

## Variant Builder v0 (Prompt H)
Документация редактора вариантов правил: `docs/variants.md`.

## Video P1 (Prompt I)
Документация по WebRTC signaling и TURN/STUN: `docs/video.md`.

## Analytics MVP (Prompt J)
Документация по событиям, логам и метрикам: `docs/analytics.md`.

## Testing contour (Prompt K)
Документация по unit/integration/e2e/load: `docs/testing.md`.

## P2 add-ons status
- UI/UX: campaigns screen + animated transitions (`animations`), store subscription tab.
- IAP: `in_app_purchase` integration with `REGION_MODE=ru_by` lock.
- Video/Voice: API token endpoints `/webrtc/*` + realtime SFU coordinator scaffold.
- Analytics: publish/query queue + Prometheus text endpoint + Sentry hook.
- Advanced tests: `tests/load.js` + extra p2 e2e test + CI audit step.

## Internal Game Generator (Prompt L)
Документация внутреннего генератора definitions/fixtures: `docs/game-generator.md`.
