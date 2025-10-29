#!/usr/bin/env bash
# multiselect/ui_multiselect.sh - loader for segmented multi-select UI
[[ -n "${UI_MULTISELECT_LOADED:-}" ]] && return 0
readonly UI_MULTISELECT_LOADED=1
_MS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"

# Shared dependencies (colors + messaging primitives)
# shellcheck source=../../colors.sh
source "${_MS_DIR}/../../colors.sh"
# shellcheck source=../../utils/msg.sh
source "${_MS_DIR}/../../utils/msg.sh"

# Segment sources
source "${_MS_DIR}/init.sh"
source "${_MS_DIR}/render.sh"
source "${_MS_DIR}/eventloop.sh"

unset _MS_DIR
