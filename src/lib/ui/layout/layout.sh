#!/usr/bin/env bash
# layout/layout.sh - Terminal rows & capacity calculation + region clearing (Phase 3)
# Returns metrics string: capacity:need_paging:rows:fixed:spacer:top:footer:base_header
# File <120 lines goal.

[[ -n "${UI_LAYOUT_LOADED:-}" ]] && return 0
readonly UI_LAYOUT_LOADED=1

# ui_layout_get_rows -> echo terminal row count (int)
ui_layout_get_rows() {
  local rows=""
  if command -v stty >/dev/null 2>&1; then
    rows=$(stty size 2>/dev/null | awk '{print $1}') || rows=""
  fi
  [[ -z "$rows" || ! "$rows" =~ ^[0-9]+$ ]] && rows=$(tput lines 2>/dev/null || echo 24)
  (( rows < 5 )) && rows=5
  echo "$rows"
}

# ui_layout_compute_capacity <rows> <fixed> <spacer> <top> <footer_lines> <filtered_count> <filter_mode>
# filter_mode: 1 if active
ui_layout_compute_capacity() {
  local rows=$1 fixed=$2 spacer=$3 top=$4 footer=$5 filtered=$6 filter_mode=$7
  local filter_extra=0 base_header cap_no_paged cap_paged need_paging=0 capacity
  [[ $filter_mode -eq 1 ]] && filter_extra=2
  base_header=$((2 + filter_extra))
  cap_no_paged=$(( rows - (fixed + spacer + top) - footer - base_header ))
  (( cap_no_paged < 0 )) && cap_no_paged=0
  if (( filtered > cap_no_paged )); then
    need_paging=1
    cap_paged=$(( rows - (fixed + spacer + top) - footer - base_header - 2 ))
    (( cap_paged < 0 )) && cap_paged=0
    capacity=$cap_paged
  else
    capacity=$cap_no_paged
  fi
  if [[ "${UI_ENV_DEBUG:-0}" == "1" ]]; then
    msg_dim "[layout] rows=$rows fixed=$fixed spacer=$spacer top=$top footer=$footer base_header=$base_header filtered=$filtered filter_mode=$filter_mode capacity=$capacity paging=$need_paging"
  fi
  echo "${capacity}:${need_paging}:${rows}:${fixed}:${spacer}:${top}:${footer}:${base_header}"
}

# ui_layout_parse_metrics <metrics_string>
# Echo key=value lines (portable; consumer can eval cautiously)
ui_layout_parse_metrics() {
  local m="$1" cap need rows fixed spacer top footer base
  cap=${m%%:*}; m=${m#*:}
  need=${m%%:*}; m=${m#*:}
  rows=${m%%:*}; m=${m#*:}
  fixed=${m%%:*}; m=${m#*:}
  spacer=${m%%:*}; m=${m#*:}
  top=${m%%:*}; m=${m#*:}
  footer=${m%%:*}; m=${m#*:}
  base=${m%%:*}
  printf 'capacity=%s\nneed_paging=%s\nrows=%s\nfixed=%s\nspacer=%s\ntop=%s\nfooter=%s\nbase_header=%s\n' \
    "$cap" "$need" "$rows" "$fixed" "$spacer" "$top" "$footer" "$base"
}

# ui_layout_clear_region <start_line>
ui_layout_clear_region() {
  local start=$1
  ui_move "$start" 1
  printf '\033[J' >&2
}

export -f ui_layout_get_rows ui_layout_compute_capacity ui_layout_parse_metrics ui_layout_clear_region
