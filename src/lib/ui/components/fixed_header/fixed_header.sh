#!/usr/bin/env bash
# components/fixed_header/fixed_header.sh - Persistent global header/banner
# Renamed & migrated from ui_fixed_header.sh. Single responsibility: manage
# a static header region above dynamic content. Exports:
#   ui_fixed_header_set, ui_fixed_header_clear, ui_fixed_header_rerender, ui_clear_content_area
# All output -> stderr.

[[ -n "${UI_COMPONENT_FIXED_HEADER_LOADED:-}" ]] && return 0
readonly UI_COMPONENT_FIXED_HEADER_LOADED=1

ui_fixed_header_set() {
  local content="$1" old_ifs="$IFS"
  [[ -z "$content" ]] && return 0
  content=$(printf '%b' "$content")
  IFS=$'\n' read -r -d '' -a UI_FIXED_HEADER_LINES < <(printf '%s' "$content" && printf '\0') || true
  IFS="$old_ifs"
  UI_FIXED_HEADER_COUNT=${#UI_FIXED_HEADER_LINES[@]}
  UI_FIXED_HEADER_SET=1
  ui_fixed_header_rerender
}

ui_fixed_header_clear() {
  unset UI_FIXED_HEADER_LINES
  UI_FIXED_HEADER_COUNT=0
  UI_FIXED_HEADER_SET=0
  UI_FIXED_HEADER_SPACER=0
  UI_FIXED_HEADER_TOP_PAD=0
}

ui_fixed_header_rerender() {
  [[ "${UI_FIXED_HEADER_SET:-0}" != 1 ]] && return 0
  local width
  if command -v stty >/dev/null 2>&1; then
    width=$(stty size 2>/dev/null | awk '{print $2}') || width=""
  fi
  [[ -z "$width" || ! "$width" =~ ^[0-9]+$ ]] && width=$(tput cols 2>/dev/null || echo 120)
  (( width < 40 )) && width=40

  ui_move 1 1
  printf '\033[J' >&2
  UI_FIXED_HEADER_TOP_PAD=1
  printf '\n' >&2

  local i line line_len padding right_pad
  for ((i=0;i<UI_FIXED_HEADER_COUNT;i++)); do
    line="${UI_FIXED_HEADER_LINES[$i]}"
    if (( i == 1 )); then
      line_len=${#line}
      if (( line_len > width - 4 )); then
        line="${line:0:$((width - 7))}..."; line_len=${#line}
      fi
      padding=$(((width - line_len)/2))
      right_pad=$((width - line_len - padding))
      printf '%s' "${C_PURPLE}" >&2
      printf '%*s' "$padding" '' >&2
      printf '%s%s%s' "${C_BOLD}${C_PURPLE}" "$line" "${C_RESET}${C_PURPLE}" >&2
      printf '%*s' "$right_pad" '' >&2
      printf '%s\n' "${C_RESET}" >&2
    else
      if [[ $i -eq 0 || $i -eq $((UI_FIXED_HEADER_COUNT - 1)) ]]; then
        # Border line must go to stderr; use a here-string to avoid stdout pipeline leakage.
        printf '%s' "${C_PURPLE}" >&2
        { printf '%*s' "$width" '' | tr ' ' '─'; printf '\n'; } >&2
        printf '%s' "${C_RESET}" >&2
      else
        printf '%-*s\n' "$width" "$line" >&2
      fi
    fi
  done
  printf '\n' >&2
  UI_FIXED_HEADER_SPACER=1
}

ui_clear_content_area() {
  if [[ "${UI_FIXED_HEADER_SET:-0}" == 1 ]]; then
    local spacer=${UI_FIXED_HEADER_SPACER:-0}
    local top=${UI_FIXED_HEADER_TOP_PAD:-0}
    local start=$((UI_FIXED_HEADER_COUNT + spacer + top + 1))
    ui_move "$start" 1
    printf '\033[J' >&2
  else
    ui_clear_screen
  fi
}

export -f ui_fixed_header_set ui_fixed_header_clear ui_fixed_header_rerender ui_clear_content_area
