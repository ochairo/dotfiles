#!/usr/bin/env bash
# msg/msg.sh - Loader for messaging utilities

[[ -n "${MSG_MODULE_LOADED:-}" ]] && return 0
readonly MSG_MODULE_LOADED=1

MSG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# shellcheck source=/dev/null
source "${MSG_DIR}/levels.sh"
# shellcheck source=/dev/null
source "${MSG_DIR}/width.sh"
# shellcheck source=/dev/null
source "${MSG_DIR}/primitives.sh"
# shellcheck source=/dev/null
source "${MSG_DIR}/emit.sh"
# shellcheck source=/dev/null
source "${MSG_DIR}/format_header.sh"
# shellcheck source=/dev/null
source "${MSG_DIR}/progress.sh"
# shellcheck source=/dev/null
source "${MSG_DIR}/config.sh"
