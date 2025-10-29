#!/usr/bin/env bash
# multiselect/state.sh - shared multiselect helper functions (Phase 7 extraction)
# Contains lightweight helpers previously embedded in render.sh.

[[ -n "${UI_MULTISELECT_STATE_LOADED:-}" ]] && return 0
readonly UI_MULTISELECT_STATE_LOADED=1

# Count filtered indices safely
ms_filtered_count() { declare -p filtered_indices &>/dev/null && echo "${#filtered_indices[@]}" || echo 0; }

# Minimum content rows (env override -> constant -> legacy fallback)
ms_min_content_rows() { ui_env_min_rows; }

# Capacity wrapper delegating to layout module
ms_compute_capacity() {
  local rows fixed spacer top footer filtered mode
  rows=$(ui_layout_get_rows)
  fixed=${UI_FIXED_HEADER_COUNT:-0}
  spacer=${UI_FIXED_HEADER_SPACER:-0}
  top=${UI_FIXED_HEADER_TOP_PAD:-0}
  footer=$(ui_footer_lines "${filter_mode:-0}")
  filtered=$(ms_filtered_count)
  mode=${filter_mode:-0}
  ui_layout_compute_capacity "$rows" "$fixed" "$spacer" "$top" "$footer" "$filtered" "$mode"
}

export -f ms_filtered_count ms_min_content_rows ms_compute_capacity
