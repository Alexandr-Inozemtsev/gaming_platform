#!/usr/bin/env bash
# Назначение файла: выполнить smoke-сценарий релизной готовности MVP через API.
# Роль в проекте: программно проверять критичный пользовательский путь login -> room -> game -> store -> apply skin.
# Основные функции: register/login, create match, move, store purchase, apply skin, итоговая валидация ответов.
# Связи с другими файлами: использует API runtime services/api/src/runtime.mjs и сценарии из docs/release-checklist.md.
# Важно при изменении: поддерживать совместимость с shell+jq и не добавлять в вывод секреты/токены.

set -euo pipefail

API_BASE_URL="${API_BASE_URL:-http://127.0.0.1:3000}"

if ! command -v jq >/dev/null 2>&1; then
  echo '[smoke] Ошибка: требуется jq. Установите jq и повторите запуск.'
  exit 1
fi

post_json() {
  local path="$1"
  local payload="$2"
  curl -sS -X POST "$API_BASE_URL$path" -H 'content-type: application/json' -d "$payload"
}

echo '[smoke] 1/6 register user'
USER_EMAIL="smoke_$(date +%s)@test.dev"
REGISTER_BODY="$(post_json '/auth/register' "{\"email\":\"$USER_EMAIL\",\"password\":\"secret01\"}")"
USER_ID="$(echo "$REGISTER_BODY" | jq -r '.id')"
[[ "$USER_ID" != "null" ]] || { echo '[smoke] register провален'; exit 1; }

echo '[smoke] 2/6 login user'
LOGIN_BODY="$(post_json '/auth/login' "{\"email\":\"$USER_EMAIL\",\"password\":\"secret01\"}")"
ACCESS_TOKEN="$(echo "$LOGIN_BODY" | jq -r '.accessToken')"
[[ "$ACCESS_TOKEN" != "null" ]] || { echo '[smoke] login провален'; exit 1; }

echo '[smoke] 3/6 create private room (match)'
MATCH_BODY="$(post_json '/matches' "{\"gameId\":\"tile_placement_demo\",\"players\":[\"$USER_ID\",\"${USER_ID}_bot\"]}")"
MATCH_ID="$(echo "$MATCH_BODY" | jq -r '.id')"
[[ "$MATCH_ID" != "null" ]] || { echo '[smoke] create match провален'; exit 1; }

echo '[smoke] 4/6 start tile game vs bot (first move)'
MOVE_BODY="$(post_json "/matches/$MATCH_ID/move" "{\"playerId\":\"$USER_ID\",\"action\":\"place\",\"moveId\":\"smoke_m1\",\"payload\":{\"row\":0,\"col\":0}}")"
MOVE_NUMBER="$(echo "$MOVE_BODY" | jq -r '.moveNumber')"
[[ "$MOVE_NUMBER" != "null" ]] || { echo '[smoke] first move провален'; exit 1; }

echo '[smoke] 5/6 store sandbox purchase'
SKUS_BODY="$(curl -sS "$API_BASE_URL/store/skus")"
COSMETIC_SKU="$(echo "$SKUS_BODY" | jq -r '.items[] | select(.type=="COSMETIC") | .sku' | head -n1)"
[[ -n "$COSMETIC_SKU" ]] || { echo '[smoke] cosmetic sku не найден'; exit 1; }
PURCHASE_BODY="$(post_json '/store/purchase-sandbox' "{\"userId\":\"$USER_ID\",\"sku\":\"$COSMETIC_SKU\"}")"
PURCHASE_OK="$(echo "$PURCHASE_BODY" | jq -r '.ok')"
[[ "$PURCHASE_OK" == "true" ]] || { echo '[smoke] purchase провален'; exit 1; }

echo '[smoke] 6/6 apply skin'
APPLY_BODY="$(post_json '/store/apply-skin' "{\"userId\":\"$USER_ID\",\"sku\":\"$COSMETIC_SKU\"}")"
APPLIED_SKU="$(echo "$APPLY_BODY" | jq -r '.appliedSku')"
[[ "$APPLIED_SKU" == "$COSMETIC_SKU" ]] || { echo '[smoke] apply skin провален'; exit 1; }

echo '[smoke] ✅ Сценарий успешен: login -> room -> tile game -> store -> apply skin'
