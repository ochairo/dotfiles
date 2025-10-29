#!/usr/bin/env bash
# select/init.sh - Guard + shared deps
[[ -n "${UI_SELECT_LOADED:-}" ]] && return 0
readonly UI_SELECT_LOADED=1
_SEL_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=../../colors.sh
source "${_SEL_DIR}/../../colors.sh"
# shellcheck source=../../utils/msg.sh
source "${_SEL_DIR}/../../utils/msg.sh"
