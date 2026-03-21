#!/usr/bin/env bash
set -euo pipefail

ENV="${ENV:-staging}"
DB_MIGRATE="${DB_MIGRATE:-true}"

echo "[prod-up] Building containers for ${ENV}"
docker build -f infra/Dockerfile --target api -t "tabletop-api:${ENV}" .
docker build -f infra/Dockerfile --target matches -t "tabletop-matches:${ENV}" .
docker build -f infra/Dockerfile --target campaigns -t "tabletop-campaigns:${ENV}" .
docker build -f infra/Dockerfile --target analytics -t "tabletop-analytics:${ENV}" .
docker build -f infra/Dockerfile --target web-socket -t "tabletop-websocket:${ENV}" .

if [[ "${DB_MIGRATE}" == "true" ]]; then
  echo "[prod-up] Applying prisma migrations"
  npx prisma migrate deploy
fi

echo "[prod-up] Applying k8s manifests"
kubectl apply -f k8s/
kubectl get pods -n tabletop
kubectl wait --for=condition=available --timeout=180s deployment/api -n tabletop
kubectl wait --for=condition=available --timeout=180s deployment/matches -n tabletop
kubectl wait --for=condition=available --timeout=180s deployment/campaigns -n tabletop
kubectl wait --for=condition=available --timeout=180s deployment/analytics -n tabletop
kubectl wait --for=condition=available --timeout=180s deployment/websocket -n tabletop
