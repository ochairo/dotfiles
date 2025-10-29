#!/usr/bin/env bash
# components/error/error.sh - Height/visibility error diagnostics (Phase 4)
# Emits 3 diagnostic lines (error, dims, warn). Legacy shim removed.
# All output to stderr.

[[ -n "${UI_COMPONENT_ERROR_LOADED:-}" ]] && return 0
readonly UI_COMPONENT_ERROR_LOADED=1

# ui_error_render
# Relies on existing helpers: ms_min_content_rows, ms_compute_capacity.
# Contract: exactly three lines (unless future minimal variant added).
ui_error_render() {
  local min metrics capacity rest need rows fixed spacer top footer base required_total
  min=$(ms_min_content_rows)
  metrics=$(ms_compute_capacity)
  capacity=${metrics%%:*}
  rest=${metrics#*:}
  need=${rest%%:*}; rest=${rest#*:}
  rows=${rest%%:*}; rest=${rest#*:}
  fixed=${rest%%:*}; rest=${rest#*:}
  spacer=${rest%%:*}; rest=${rest#*:}
  top=${rest%%:*}; rest=${rest#*:}
  footer=${rest%%:*}; rest=${rest#*:}
  base=${rest%%:*}
  msg_error "Not enough visible rows for content (need >= ${min}, have ${capacity})"
  msg_dim "rows=${rows} fixed_block=$((fixed+spacer+top)) base_header=${base} footer=${footer} paging=${need} visible_capacity=${capacity} required_min=${min}"
  required_total=$((fixed+spacer+top+base + (need*2) + footer + min))
  if [[ "${UI_ENV_DEBUG:-0}" == "1" ]]; then
    msg_dim "[error] required_total=${required_total} rows=${rows} base_header=${base} footer=${footer} min=${min} paging=${need}"
  fi
  msg_warn "Resize terminal to at least ${required_total} rows to display options"
}

export -f ui_error_render
