# Deploy: staging/prod (P2)

## Переменные запуска
- `ENV=staging|prod`
- `DB_MIGRATE=true|false`
- `ASSET_BASE_URL=https://cdn.<env>.tabletopplatform.example` (фиксируется отдельно для dev/stage/prod)

## Что добавлено в P2
- Мульти-таргет сборка контейнеров `infra/Dockerfile`: `api`, `matches`, `campaigns`, `analytics`, `web-socket`.
- Kubernetes-манифесты в `k8s/`: namespace, configmap, deployments, services, ingress.
- Prisma schema + SQL-миграция для таблиц `campaigns`, `events`, `rewards`, `leaderboards`, `levels`, `legacy_*`, `coop_sessions`.
- CI-шаги для `docker build` всех таргетов и `kubectl apply --dry-run=client -f k8s/`.

## Сборка docker-образов
```bash
docker build -f infra/Dockerfile --target api -t tabletop-api:${ENV:-staging} .
docker build -f infra/Dockerfile --target matches -t tabletop-matches:${ENV:-staging} .
docker build -f infra/Dockerfile --target campaigns -t tabletop-campaigns:${ENV:-staging} .
docker build -f infra/Dockerfile --target analytics -t tabletop-analytics:${ENV:-staging} .
docker build -f infra/Dockerfile --target web-socket -t tabletop-websocket:${ENV:-staging} .
```

## Применение миграций
```bash
if [ "${DB_MIGRATE:-true}" = "true" ]; then
  npx prisma migrate deploy
fi
```

## Деплой в Kubernetes
```bash
kubectl apply -f k8s/
kubectl get pods -n tabletop
kubectl get ingress -n tabletop
kubectl wait --for=condition=available --timeout=180s deployment/api -n tabletop
kubectl wait --for=condition=available --timeout=180s deployment/matches -n tabletop
kubectl wait --for=condition=available --timeout=180s deployment/campaigns -n tabletop
kubectl wait --for=condition=available --timeout=180s deployment/analytics -n tabletop
kubectl wait --for=condition=available --timeout=180s deployment/websocket -n tabletop
```

## One-command deploy
Из корня репозитория:
```bash
npm run prod-up
```

## CI для контейнеров и k8s
- `.github/workflows/ci.yml` запускает `docker build` для всех P2 сервисов.
- Затем выполняется `kubectl apply --dry-run=client -f k8s/` для валидации манифестов.

## DevOps Dashboard (ASCII)
`[API] Running ✅ [Matches] Running ✅ [Campaign] Running ✅ [DB Migration] Applied ✅ [Kubernetes] Deployed ✅`
