#!/usr/bin/env bash
# shim: expose component operations (list only) from nested directory
set -euo pipefail

# Locate actual component command script
COMPONENT_CMD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/component"
REAL_CMD="$COMPONENT_CMD_DIR/component.sh"
if [[ ! -f "$REAL_CMD" ]]; then
  echo "component command backend missing: $REAL_CMD" >&2
  exit 1
fi
# Ensure libraries are loaded (mirrors bin/dot behavior for direct sourcing)
if [[ -z "${LIB_DIR:-}" ]]; then
  DOTFILES_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../../.." && pwd)"
  SRC_DIR="$DOTFILES_ROOT/src"
  LIB_DIR="$SRC_DIR/lib"
  CORE_DIR="$SRC_DIR/core"
  export DOTFILES_ROOT SRC_DIR LIB_DIR CORE_DIR
  [[ -f "$LIB_DIR/index.sh" ]] && source "$LIB_DIR/index.sh"
  [[ -f "$CORE_DIR/index.sh" ]] && source "$CORE_DIR/index.sh"
fi

# shellcheck source=/dev/null
source "$REAL_CMD" "$@"
