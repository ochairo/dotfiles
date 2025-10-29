#!/usr/bin/env bash
# multiselect/handlers.sh - resize & cursor helpers (orchestrator slimming)
# <120 lines; single responsibility: auxiliary handlers for multiselect.

[[ -n "${UI_MULTISELECT_HANDLERS_LOADED:-}" ]] && return 0
readonly UI_MULTISELECT_HANDLERS_LOADED=1

ms_handle_resize() {
  # Mark pending resize; force header + full clear path
  UI_MULTISELECT_PENDING_RESIZE=1
  UI_MULTISELECT_NEEDS_HEADER=1
  # Treat next render like a first render to guarantee full screen purge
  UI_MULTISELECT_FIRST_RENDER=1
}

# Place cursor at end of live filter input
ms_filter_cursor_place() {
  local filter_row=$1 base_prefix="${UI_ICON_FILTER:-⌕} Filter (live): "
  local col=$(( ${#base_prefix} + ${#filter} + 1 ))
  ui_move "$filter_row" "$col"
  ui_show_cursor 2>/dev/null || true
}

export -f ms_handle_resize ms_filter_cursor_place
