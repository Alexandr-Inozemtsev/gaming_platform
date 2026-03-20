# Deploy: staging/prod (MVP)

## Что добавлено
- Dockerfile для сервисов: `api`, `realtime`, `admin`, `rules-engine`.
- `docker-compose.prod.yml` для локального smoke-запуска production-контура.
- Шаблоны окружения: `infra/.env.staging.example`, `infra/.env.prod.example`.
- Placeholder ingress/CDN-конфиг: `infra/cdn/nginx.cdn.conf`.

## Быстрый запуск staging-подобного окружения
```bash
cp infra/.env.staging.example .env
npm install
docker compose -f docker-compose.prod.yml --env-file .env up -d --build
```

Проверки:
```bash
curl -s http://localhost:${CDN_HTTP_PORT:-8080}/health
curl -s http://localhost:${CDN_HTTP_PORT:-8080}/api/games
curl -s http://localhost:${CDN_HTTP_PORT:-8080}/realtime/health
curl -s http://localhost:${CDN_HTTP_PORT:-8080}/admin/health
curl -s http://localhost:${CDN_HTTP_PORT:-8080}/rules/health
```

## Прод-шаблон
1. Скопируйте `infra/.env.prod.example` в защищённый секрет-стор (не в git).
2. Обновите `JWT_SECRET`, `ADMIN_PASSWORD`, `POSTGRES_PASSWORD`.
3. Запускайте `docker compose -f docker-compose.prod.yml --env-file <secure_env> up -d --build`.

## Замечания
- TLS в MVP не терминируется в `nginx.cdn.conf`; ожидается внешний LB/CDN.
- `REQUIRE_TLS_IN_PROD=true` должен оставаться включённым.
- Текущие runtime-обвязки сервисов — минимальные HTTP-раннеры для контейнерного запуска и healthcheck.
