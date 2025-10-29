#!/usr/bin/env bash
# validate_ui_lengths.sh - Ensure each UI source file < 120 lines
set -euo pipefail
LIMIT=120
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET_DIR="$ROOT/src/lib/ui"
fail=0
while IFS= read -r -d '' file; do
  lines=$(wc -l "$file" | awk '{print $1}')
  if (( lines > LIMIT )); then
    echo "[FAIL] $file has $lines lines (limit $LIMIT)" >&2
    fail=1
  fi
done < <(find "$TARGET_DIR" -type f -name '*.sh' -print0)
if (( fail )); then
  echo "UI length validation failed" >&2
  exit 1
else
  echo "All UI files within ${LIMIT} line limit" >&2
fi
