#!/usr/bin/env bash
# compatibility loader for legacy tests expecting utilities/msg path
# Delegates to current utils/msg loader

if [[ -n "${MSG_MODULE_LOADED:-}" ]]; then
  return 0
fi
# shellcheck source=/dev/null
source "$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")/../.." && pwd)/utils/msg/msg.sh"
