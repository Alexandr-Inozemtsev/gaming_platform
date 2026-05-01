#!/usr/bin/env bash
set -euo pipefail

# Big Walker -> Unity project sync script
# Usage:
#   ./push_to_unity_project.sh <UNITY_PROJECT_PATH> [--clean] [--dry-run]

if [[ $# -lt 1 ]]; then
  echo "Usage: $0 <UNITY_PROJECT_PATH> [--clean] [--dry-run]"
  exit 1
fi

UNITY_PROJECT_PATH="$1"
shift || true

CLEAN=false
DRY_RUN=false

for arg in "$@"; do
  case "$arg" in
    --clean) CLEAN=true ;;
    --dry-run) DRY_RUN=true ;;
    *)
      echo "Unknown argument: $arg"
      echo "Usage: $0 <UNITY_PROJECT_PATH> [--clean] [--dry-run]"
      exit 1
      ;;
  esac
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STARTER_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SOURCE_ASSETS="$STARTER_ROOT/Assets"
TARGET_ASSETS="$UNITY_PROJECT_PATH/Assets"
TARGET_SCRIPTS="$TARGET_ASSETS/Scripts"

if [[ ! -d "$SOURCE_ASSETS" ]]; then
  echo "[error] Source Assets folder not found: $SOURCE_ASSETS"
  exit 1
fi

if [[ ! -d "$TARGET_ASSETS" ]]; then
  echo "[error] Unity target Assets folder not found: $TARGET_ASSETS"
  exit 1
fi

echo "[sync] Source: $SOURCE_ASSETS"
echo "[sync] Target: $TARGET_ASSETS"

action() {
  if $DRY_RUN; then
    echo "[dry-run] $*"
  else
    eval "$*"
  fi
}

if $CLEAN && [[ -d "$TARGET_SCRIPTS" ]]; then
  echo "[sync] Cleaning target Scripts folder: $TARGET_SCRIPTS"
  action "rm -rf '$TARGET_SCRIPTS'"
fi

# Copy Big Walker scripts into Unity Assets/Scripts preserving structure
mkdir -p "$TARGET_SCRIPTS"
action "cp -R '$SOURCE_ASSETS/Scripts/.' '$TARGET_SCRIPTS/'"

echo "[sync] Done. Return focus to Unity Editor to trigger script reimport."
echo "[next] In scene: Create Empty -> Bootstrap -> Add Component BigWalkerSceneBootstrap"
