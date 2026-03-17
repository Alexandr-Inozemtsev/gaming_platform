# TabletopPlatform Monorepo

Монорепозиторий MVP для цифровой платформы настольных игр.

## Параметры MVP
- **Название приложения:** `TabletopPlatform`
- **Режим региона:** `global` (допустимы `global` и `ru_by`)
- **Языки интерфейса:** `ru`, `en`
- **Игры MVP:** `tile_placement_demo`, `roll_and_write_demo`

## Структура репозитория
- `apps/mobile` — Flutter-клиент (каркас приложения)
- `services/api` — backend API (TypeScript-заглушка)
- `services/realtime` — realtime-шлюз (TypeScript-заглушка)
- `services/rules-engine` — библиотека игровых правил
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
