#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <UNITY_PROJECT_PATH> [--clean]"
  exit 1
fi

UNITY_PROJECT_PATH="$1"
CLEAN="false"
if [[ "${2:-}" == "--clean" ]]; then
  CLEAN="true"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_SCRIPTS="$SOURCE_ROOT/Assets/Scripts"
TARGET_ASSETS="$UNITY_PROJECT_PATH/Assets"
TARGET_SCRIPTS="$TARGET_ASSETS/Scripts"

if [[ ! -d "$SOURCE_SCRIPTS" ]]; then
  echo "Source scripts not found: $SOURCE_SCRIPTS"
  exit 1
fi

if [[ ! -d "$TARGET_ASSETS" ]]; then
  echo "Unity project Assets folder not found: $TARGET_ASSETS"
  exit 1
fi

echo "[sync] Source: $SOURCE_SCRIPTS"
echo "[sync] Target: $TARGET_SCRIPTS"

if [[ "$CLEAN" == "true" && -d "$TARGET_SCRIPTS" ]]; then
  echo "[sync] Cleaning target Scripts folder"
  rm -rf "$TARGET_SCRIPTS"
fi

mkdir -p "$TARGET_SCRIPTS"
cp -R "$SOURCE_SCRIPTS"/* "$TARGET_SCRIPTS"/

echo "[sync] Done. Return focus to Unity to trigger reimport."
