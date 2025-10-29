#!/usr/bin/env bash
# multiselect/init.sh - state initialization & cleanup for multi-select UI

[[ -n "${UI_MULTISELECT_INIT_LOADED:-}" ]] && return 0
readonly UI_MULTISELECT_INIT_LOADED=1

# Global state variables (predeclared for analyzers / shellcheck)
prompt=""
options=()
total=0
selected_status=()
filtered_indices=()
cursor=0
filter=""
filter_mode=0
page=0
page_size=0
total_pages=0
start_idx=0
end_idx=0
AM_HEADER_LINES=0
AM_PAGE_ITEMS=0
AM_FOOTER_START=0

# Initialize global state for multi-select session.
# Arguments: prompt, options...
ms_init_state() {
  # Initialize multiselect session state. Safe under `set -u`.
  # IMPORTANT: Do NOT use `declare -a` here; inside a function it creates local arrays.
  # We need globals so rendering/eventloop functions can access them after return.
  [[ $# -lt 2 ]] && msg_error "ms_init_state requires prompt and at least one option" && return 1
  prompt="$1"; shift
  options=("$@")
  total=${#options[@]}
  if [[ $total -eq 0 ]]; then
    msg_warn "No options provided"
    return 1
  fi
  # Reset global arrays
  unset selected_status filtered_indices
  selected_status=()
  filtered_indices=()
  cursor=0
  filter=""
  page=0
  page_size=10
  total_pages=1
  local i
  for ((i=0;i<total;i++)); do
    selected_status[$i]=0
    filtered_indices+=("$i")
  done
  ms_recompute_page_metrics
}

# Recompute page metrics based on terminal size + filtered item count.
ms_recompute_page_metrics() {
  # Fallbacks to avoid unbound variables under set -u
  local footer_lines header_base header_paged min_rows
  footer_lines=$(ui_footer_lines 0)             # non-filter mode footer height
  header_base=2                                 # lines when not paged
  header_paged=4                                # lines when paged (adds page info block)
  min_rows="${UI_ENV_MIN_ROWS:-${UI_MIN_DEFAULT_ROWS:-3}}"
  # Compute raw size based on terminal and item count
  local computed count min_floor=5 max_cap=10
  computed=$(ui_recompute_page_size \
    ${#filtered_indices[@]} \
    "$footer_lines" "$header_base" "$header_paged" "$min_rows")
  count=${#filtered_indices[@]}
  page_size=$computed
  # Enforce minimum visible rows (5) unless fewer items available
  if (( page_size < min_floor )); then
    if (( count < min_floor )); then
      page_size=$count
    else
      page_size=$min_floor
    fi
  fi
  # Cap at usability maximum
  (( page_size > max_cap )) && page_size=$max_cap
  # Don't exceed number of items
  (( page_size > count )) && page_size=$count
  total_pages=$(ui_pages_total ${#filtered_indices[@]} "$page_size")
  ms_calc_bounds
}

# Calculate current page bounds -> start_idx / end_idx globals.
ms_calc_bounds() {
  # Parse page bounds without relying on global IFS (robust against prior IFS changes)
  local bounds start end
  bounds="$(ui_page_bounds "$page" "$page_size" ${#filtered_indices[@]})"
  # Split using parameter expansion
  start="${bounds%% *}"
  end="${bounds##* }"
  # Fallback safety: ensure numeric
  [[ ! $start =~ ^[0-9]+$ ]] && start=0
  [[ ! $end =~ ^[0-9]+$ ]] && end=0
  start_idx=$start
  end_idx=$end
}

# Cleanup global state variables to avoid leaking across sessions.
ms_cleanup_state() {
  unset prompt options total selected_status filtered_indices cursor filter filter_mode page page_size total_pages start_idx end_idx AM_HEADER_LINES AM_PAGE_ITEMS AM_FOOTER_START
}
