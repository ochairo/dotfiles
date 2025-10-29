#!/usr/bin/env bash
# components/footer/footer.sh - Footer (selection summary + help lines) Phase 5
# Provides ui_footer_lines, ui_footer_render. Legacy shims removed.
# All output to stderr.

[[ -n "${UI_COMPONENT_FOOTER_LOADED:-}" ]] && return 0
readonly UI_COMPONENT_FOOTER_LOADED=1

# ui_footer_lines <filter_mode>
# Returns number of footer lines (including surrounding blanks)
# Logic preserved from original ms_footer_lines.
ui_footer_lines() {
  local filter_mode=${1:-0}
  if [[ $filter_mode -eq 1 ]]; then
    echo 6   # blank + summary + blank + 2 help lines + blank
  else
    echo 10  # blank + summary + blank + 6 help lines + blank
  fi
}

# _ui_footer_selection_summary -> echoes formatted summary line
_ui_footer_selection_summary() {
  local total=${total:-0} idx selected_count=0 names="" raw name
  for ((idx=0; idx<total; idx++)); do
    [[ -z "${selected_status[$idx]+x}" ]] && selected_status[$idx]=0
    if [[ "${selected_status[$idx]}" == 1 ]]; then
      ((selected_count++))
      raw="${options[$idx]}"; name="${raw%% - *}"
      names="${names:+$names, }${name}"
    fi
  done
  if (( selected_count > 0 )); then
    msg_with_icon "${UI_ICON_SELECTED:-✓}" "$C_GREEN" "Selected (${selected_count}): ${names}"
  else
    msg_dim "Selected: none"
  fi
}

# ui_footer_render <filter_mode> <page_size>
# Decides navigation line variant based on filtered count > page_size.
ui_footer_render() {
  local filter_mode=${1:-0} page_size=${2:-0} filtered_count
  filtered_count=$(declare -p filtered_indices &>/dev/null && echo "${#filtered_indices[@]}" || echo 0)
  msg_blank
  _ui_footer_selection_summary
  msg_blank
  if [[ $filter_mode -eq 1 ]]; then
    msg_print "${C_DIM}${UI_HELP_FILTER_SELECT}${C_RESET}\n"
    msg_print "${C_DIM}${UI_HELP_FILTER_EXIT}${C_RESET}\n"
  else
    if [[ $filtered_count -gt $page_size ]]; then
      msg_print "${C_DIM}${UI_HELP_MULTISELECT_NAV_PAGED}${C_RESET}\n"
    else
      msg_print "${C_DIM}${UI_HELP_MULTISELECT_NAV_SIMPLE}${C_RESET}\n"
    fi
    msg_print "${C_DIM}${UI_HELP_MULTISELECT_SELECT}${C_RESET}\n"
    msg_print "${C_DIM}${UI_HELP_MULTISELECT_FILTER}${C_RESET}\n"
    msg_print "${C_DIM}${UI_HELP_MULTISELECT_CONFIRM}${C_RESET}\n"
    msg_print "${C_DIM}${UI_HELP_MULTISELECT_BACK}${C_RESET}\n"
    msg_print "${C_DIM}${UI_HELP_MULTISELECT_EXIT}${C_RESET}\n"
  fi
  msg_blank
}

# Compatibility shims ---------------------------------------------------------
export -f ui_footer_lines ui_footer_render
