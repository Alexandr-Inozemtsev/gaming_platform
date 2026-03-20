#!/usr/bin/env bash
# Назначение файла: автоматизировать локальный запуск MVP-контура одной командой для релизной проверки.
# Роль в проекте: поднимать инфраструктуру, запускать backend-сервисы и подсказывать команды Flutter для эмуляторов.
# Основные функции: docker compose up, старт API/Realtime/Admin/Rules в фоне, вывод статуса и подсказок Android/iOS.
# Связи с другими файлами: использует infra/docker-compose.yml, runtime-файлы сервисов и scripts/smoke.sh.
# Важно при изменении: не добавлять секреты, сохранять совместимость с Node.js 20+ и не блокировать терминал долгими foreground-процессами.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
LOG_DIR="$ROOT_DIR/.tmp/dev-logs"
PID_DIR="$ROOT_DIR/.tmp/dev-pids"
mkdir -p "$LOG_DIR" "$PID_DIR"

ANDROID_DEVICE="${ANDROID_DEVICE:-emulator-5554}"
IOS_DEVICE="${IOS_DEVICE:-iPhone 15}"
REGION_MODE="${REGION_MODE:-global}"

printf '\n[dev-up] Шаг 1/4: поднимаем инфраструктуру Docker...\n'
(
  cd "$ROOT_DIR/infra"
  docker compose -f docker-compose.yml up -d
)

start_service() {
  local service_name="$1"
  local port_var_name="$2"
  local port_value="$3"
  local entrypoint="$4"
  local log_file="$LOG_DIR/${service_name}.log"
  local pid_file="$PID_DIR/${service_name}.pid"

  if [[ -f "$pid_file" ]] && kill -0 "$(cat "$pid_file")" 2>/dev/null; then
    printf '[dev-up] %s уже запущен (pid=%s).\n' "$service_name" "$(cat "$pid_file")"
    return
  fi

  printf '[dev-up] Запускаем %s на порту %s...\n' "$service_name" "$port_value"
  (
    cd "$ROOT_DIR"
    env REGION_MODE="$REGION_MODE" "$port_var_name"="$port_value" node "$entrypoint" >"$log_file" 2>&1 &
    echo $! >"$pid_file"
  )
}

printf '\n[dev-up] Шаг 2/4: поднимаем backend runtime...\n'
start_service "api" "API_PORT" "3000" "services/api/src/runtime.mjs"
start_service "realtime" "REALTIME_PORT" "3001" "services/realtime/src/runtime.mjs"
start_service "admin" "ADMIN_PORT" "3002" "services/admin/src/runtime.mjs"
start_service "rules-engine" "RULES_ENGINE_PORT" "3003" "services/rules-engine/src/runtime.mjs"

printf '\n[dev-up] Шаг 3/4: быстрый API smoke...\n'
"$ROOT_DIR/scripts/smoke.sh" || {
  printf '[dev-up] Внимание: smoke-сценарий завершился с ошибкой. Проверьте логи в %s\n' "$LOG_DIR"
  exit 1
}

printf '\n[dev-up] Шаг 4/4: команды Flutter для эмуляторов.\n'
printf '  Android: cd apps/mobile && flutter run -d %s\n' "$ANDROID_DEVICE"
printf '  iOS:     cd apps/mobile && flutter run -d "%s"\n' "$IOS_DEVICE"
printf '\n[dev-up] Готово. Логи сервисов: %s\n' "$LOG_DIR"
printf '[dev-up] Для остановки используйте: scripts/dev-down.sh\n\n'
