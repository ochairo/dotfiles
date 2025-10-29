#!/usr/bin/env bash
# select/ui_select.sh loader - sources segmented select UI modules
[[ -n "${UI_SELECT_SEGMENTS_LOADED:-}" ]] && return 0
readonly UI_SELECT_SEGMENTS_LOADED=1
_select_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "${_select_dir}/init.sh"
source "${_select_dir}/render.sh"
source "${_select_dir}/eventloop.sh"
unset _select_dir
