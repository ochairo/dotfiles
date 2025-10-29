#!/usr/bin/env bash
# legacy stub: msg.sh now segmented under msg/
[[ -n "${MSG_STUB_LOADED:-}" ]] && return 0
readonly MSG_STUB_LOADED=1
MSG_MODULE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=/dev/null
source "${MSG_MODULE_ROOT}/msg/msg.sh"
