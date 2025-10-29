#!/usr/bin/env bash
# components/pageinfo/pageinfo.sh - Pagination page info renderer
# Single responsibility: render a page info line given current paging metrics.
# All output goes to stderr. Keeps formatting consistent across header & select UIs.

[[ -n "${UI_COMPONENT_PAGEINFO_LOADED:-}" ]] && return 0
readonly UI_COMPONENT_PAGEINFO_LOADED=1

# ui_render_page_info <current_page> <total_pages> <start_index> <end_index> <total_items>
# Notes:
#   * current_page is zero-based internally; display is 1-based.
#   * end_index is exclusive; we display end_index (converted to 1-based) as the last shown item.
ui_render_page_info() {
  local current=${1:-0} total_pages=${2:-1} start=${3:-0} end=${4:-0} total_items=${5:-0}
  local disp_page=$((current + 1))
  local disp_start=$((start + 1))
  local disp_end=$((end))
  (( disp_end < disp_start )) && disp_end=$disp_start
  printf 'Page %d/%d (showing %d-%d of %d)\n' "$disp_page" "$total_pages" "$disp_start" "$disp_end" "$total_items" >&2
}

export -f ui_render_page_info
