#!/usr/bin/env bash
# components/options/options.sh - Option formatting & list rendering (Phase 1 extraction)
# Provides generic prefix/checkbox formatting plus a bulk renderer.
# Legacy shims (ms_format_option, ms_render_options_full) scheduled for removal.
# All output goes to stderr.

[[ -n "${UI_COMPONENT_OPTIONS_LOADED:-}" ]] && return 0
readonly UI_COMPONENT_OPTIONS_LOADED=1

# ui_option_prefix <is_cursor>
ui_option_prefix() {
  local raw=${1:-0} is_cursor=0
  case "$raw" in
    1|true|TRUE|current|CURRENT|cursor|CURSOR) is_cursor=1 ;;
  esac
  if (( is_cursor )); then
    printf '%b' "${C_CYAN}❯ ${C_RESET}" >&2
  else
    printf '%s' "  " >&2
  fi
}

# ui_option_checkbox <selected_flag>
ui_option_checkbox() {
  local raw=${1:-0} flag=0
  case "$raw" in
    1|true|TRUE|yes|YES|checked|CHECKED|on|ON) flag=1 ;;
  esac
  if (( flag )); then
    printf '%b' "${C_GREEN}☑${C_RESET}" >&2
  else
    printf '%b' "${C_DIM}☐${C_RESET}" >&2
  fi
}

# ui_option_format <logical_index> <display_index>
# Uses globals: filtered_indices[], options[], selected_status[], cursor.
ui_option_format() {
  local logical_index="$1" display_index="$2" opt_index is_current is_selected prefix checkbox count
  count="$(declare -p filtered_indices &>/dev/null && echo "${#filtered_indices[@]}" || echo 0)"
  [[ $count -eq 0 ]] && return 0
  opt_index="${filtered_indices[$logical_index]}"
  is_current=0; [[ $display_index -eq ${cursor:-0} ]] && is_current=1
  is_selected=0; [[ "${selected_status[$opt_index]:-0}" == 1 ]] && is_selected=1
  ui_option_prefix "$is_current"
  printf ' ' >&2
  ui_option_checkbox "$is_selected"
  printf ' %s' "${options[$opt_index]}" >&2
}

# ui_options_render
# Renders currently visible options in range [start_idx, end_idx) using globals.
ui_options_render() {
  local display_count=0 count
  count="$(declare -p filtered_indices &>/dev/null && echo "${#filtered_indices[@]}" || echo 0)"
  if [[ $count -eq 0 ]]; then
    msg_blank
    msg_dim "No matches found"
    return 0
  fi
  local li
  for ((li=${start_idx:-0}; li<${end_idx:-0}; li++)); do
    ui_option_format "$li" "$display_count"
    printf '\n' >&2
    ((display_count++))
  done
}

# Backward compatibility shims ------------------------------------------------
export -f ui_option_prefix ui_option_checkbox ui_option_format ui_options_render
