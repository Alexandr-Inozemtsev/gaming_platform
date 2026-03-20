#!/usr/bin/env bash
# Назначение файла: корректно остановить локально запущенный dev-контур MVP.
# Роль в проекте: завершать фоновые backend-процессы из scripts/dev-up.sh и выключать docker-инфраструктуру.
# Основные функции: kill по PID-файлам и docker compose down.
# Связи с другими файлами: использует .tmp/dev-pids и infra/docker-compose.yml.
# Важно при изменении: удалять PID-файлы только после успешной остановки процесса.

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PID_DIR="$ROOT_DIR/.tmp/dev-pids"

if [[ -d "$PID_DIR" ]]; then
  for pid_file in "$PID_DIR"/*.pid; do
    [[ -f "$pid_file" ]] || continue
    pid="$(cat "$pid_file")"
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid" || true
      printf '[dev-down] Остановлен процесс pid=%s (%s).\n' "$pid" "$(basename "$pid_file")"
    fi
    rm -f "$pid_file"
  done
fi

(
  cd "$ROOT_DIR/infra"
  docker compose -f docker-compose.yml down
)

printf '[dev-down] Локальный контур остановлен.\n'
