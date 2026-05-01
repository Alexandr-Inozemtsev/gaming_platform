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
TARGET_ASSETS="$UNITY_PROJECT_PATH/Assets"
TARGET_SCRIPTS="$TARGET_ASSETS/Scripts"

if [[ ! -d "$SOURCE_SCRIPTS" ]]; then
  echo "Source not found: $SOURCE_SCRIPTS"
  exit 1
fi

if [[ ! -d "$TARGET_ASSETS" ]]; then
  echo "Unity Assets folder not found: $TARGET_ASSETS"
  exit 1
fi

echo "[sync] Removing old BigWalker C# scripts across Unity Assets..."
while IFS= read -r oldFile; do
  rm -f "$oldFile"
  echo "[sync] removed: $oldFile"
done < <(find "$TARGET_ASSETS" -type f \( -name 'BigWalker*.cs' -o -name 'BigWalker*.cs.meta' \))

echo "[sync] Recreating target scripts folder: $TARGET_SCRIPTS"
rm -rf "$TARGET_SCRIPTS"
mkdir -p "$TARGET_SCRIPTS"

echo "[sync] Copying latest starter scripts..."
cp -R "$SOURCE_SCRIPTS"/. "$TARGET_SCRIPTS/"

echo "[sync] Done: scripts copied to $TARGET_SCRIPTS"
echo "[next] In Unity: Assets -> Reimport All, then press Play"
echo "[next] You should see Select Players screen before gameplay"
