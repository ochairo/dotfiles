#!/usr/bin/env bash
# components/header/header.sh - Header (prompt + optional pagination) Phase 6
# Provides ui_header_lines, ui_header_render. Legacy ms_* shims removed.
# All output directed to stderr via msg_* utilities.

[[ -n "${UI_COMPONENT_HEADER_LOADED:-}" ]] && return 0
readonly UI_COMPONENT_HEADER_LOADED=1

# header_filtered_count - local count helper (doesn't rely on multiselect shim)
header_filtered_count() { declare -p filtered_indices &>/dev/null && echo "${#filtered_indices[@]}" || echo 0; }

# ui_header_lines <filter_mode> <page_size> <filtered_count>
# Computes header line count including pagination info lines and optional filter stub.
# Base: 2 (prompt + blank)
# +2 if filtered_count > page_size (pagination info + blank)
# +2 if filter_mode == 1 (filter bar + blank reserved area)
ui_header_lines() {
  local filter_mode=${1:-0} page_size=${2:-0} filtered_count=${3:-0}
  local lines=2
  if [[ $filtered_count -gt $page_size ]]; then
    lines=$((lines+2))
  fi
  if [[ $filter_mode -eq 1 ]]; then
    lines=$((lines+2))
  fi
  echo "$lines"
}

# ui_header_render <prompt> <filter_mode> <page_size> <page> <total_pages> <start_idx> <end_idx> <filtered_count>
# Renders header (prompt line + blank + optional page info block + blank). Pagination when filtered_count > page_size.
ui_header_render() {
  local prompt="$1" filter_mode=${2:-0} page_size=${3:-0} page=${4:-1} total_pages=${5:-1} start_idx=${6:-0} end_idx=${7:-0} filtered_count=${8:-0}
  msg_with_icon "${UI_ICON_WRENCH:-🔧}" "$C_PURPLE" "$prompt"
  msg_blank
  if [[ $filtered_count -gt $page_size ]]; then
    ui_render_page_info "$page" "$total_pages" "$start_idx" "$end_idx" "$filtered_count"
    msg_blank
  fi
  # Filter mode does not render here; spacing reserved and handled by caller (multiselect orchestrator).
}

# ui_header_render_compact <prompt>
# Minimal variant: prompt + single blank line (no pagination block even if multiple pages).
ui_header_render_compact() {
  local prompt="$1"
  msg_with_icon "${UI_ICON_WRENCH:-🔧}" "$C_PURPLE" "$prompt"
  msg_blank
}

# Compatibility shims ---------------------------------------------------------
export -f ui_header_lines ui_header_render ui_header_render_compact header_filtered_count
