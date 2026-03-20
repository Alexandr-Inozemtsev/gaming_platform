# Инфраструктура MVP (локальная разработка и CI)

## Назначение
Этот документ описывает, как в MVP поднимать локальную инфраструктуру и какие автопроверки выполняются в CI.

## Состав локальной инфраструктуры
- **PostgreSQL 16**: основное хранилище данных.
- **Redis 7**: кэш и временное состояние realtime-сценариев.

Конфигурация хранится в `infra/docker-compose.yml`, а шаблон переменных — в `infra/.env.example`.

## Переменные окружения
Пример ключевых переменных:
- `POSTGRES_DB=tabletop`
- `POSTGRES_USER=tabletop`
- `POSTGRES_PASSWORD=tabletop_dev`
- `POSTGRES_PORT=5432`
- `REDIS_PORT=6379`
- `API_PORT=3000`
- `REALTIME_PORT=3001`
- `REGION_MODE=global` (допустимые значения: `global`, `ru_by`)

> Секреты в репозиторий не коммитим: используем только шаблон `.env.example`.

## Как запускать локально
```bash
cd infra
cp .env.example .env
docker compose up -d
docker compose logs -f
```

### Healthcheck
В `docker-compose.yml` настроены healthcheck для:
- Postgres через `pg_isready`
- Redis через `redis-cli ping`

## CI-проверки
Workflow: `.github/workflows/ci.yml`

Запускаются два job:
1. **backend**
   - `npm ci`
   - `npm run lint`
   - `npm test`
2. **mobile**
   - `flutter pub get`
   - `flutter analyze`

Pipeline падает, если нарушен lint, упали unit-тесты или анализ Flutter-кода завершился с ошибкой.
