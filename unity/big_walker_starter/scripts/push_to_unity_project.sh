#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   ./push_to_unity_project.sh /absolute/path/to/UnityProject

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <UNITY_PROJECT_PATH>"
  exit 1
fi

UNITY_PROJECT_PATH="$1"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STARTER_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

SOURCE_SCRIPTS="$STARTER_ROOT/Assets/Scripts"
TARGET_SCRIPTS="$UNITY_PROJECT_PATH/Assets/Scripts"

if [[ ! -d "$SOURCE_SCRIPTS" ]]; then
  echo "Source not found: $SOURCE_SCRIPTS"
  exit 1
fi

if [[ ! -d "$UNITY_PROJECT_PATH/Assets" ]]; then
  echo "Unity Assets folder not found: $UNITY_PROJECT_PATH/Assets"
  exit 1
fi

rm -rf "$TARGET_SCRIPTS"
mkdir -p "$TARGET_SCRIPTS"
cp -R "$SOURCE_SCRIPTS"/. "$TARGET_SCRIPTS/"

echo "Done: scripts copied to $TARGET_SCRIPTS"
echo "Open Unity and wait for script reimport."
