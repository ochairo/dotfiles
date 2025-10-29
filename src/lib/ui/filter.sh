#!/usr/bin/env bash
# filter.sh - Interactive filter prompt (renamed from ui_filter.sh)
ui_filter_prompt() {
  local prompt="$1"; shift || true
  local value="${1:-}" key applied=0
  ui_show_cursor 2>/dev/null || true
  printf '%s%s' "$prompt" "$value" >&2
  while IFS= read -rsn1 key; do
    case "$key" in
      $'\x1b') applied=0; value=""; break ;; # ESC
      $'\n'|$'\r') applied=1; break ;;        # ENTER
      $'\x7f') if [[ -n "$value" ]]; then value=${value%?}; printf '\r\033[2K%s%s' "$prompt" "$value" >&2; fi ;;
      $'\x15') value=""; printf '\r\033[2K%s' "$prompt" >&2 ;; # Ctrl-U
      *) if printf %s "$key" | LC_ALL=C grep -q '^[[:print:]]$'; then value+="$key"; printf '%s' "$key" >&2; fi ;;
    esac
  done < /dev/tty
  ui_hide_cursor 2>/dev/null || true
  if (( applied )); then printf '%s' "$value"; return 0; fi
  return 1
}
ui_filter_apply() {
  local filter="$1" opts_name="$2" out_name="$3"; eval "$out_name=()"; local total; eval "total=\${#${opts_name}[@]}"
  if [[ -z "$filter" ]]; then local i; for ((i=0;i<total;i++)); do eval "$out_name+=(\"$i\")"; done; return 0; fi
  local filter_lower name_lower option_value name_part i; filter_lower=$(echo "$filter" | tr '[:upper:]' '[:lower:]')
  for ((i=0;i<total;i++)); do eval "option_value=\"\${${opts_name}[i]}\""; if [[ "$option_value" == *" - "* ]]; then name_part="${option_value%% - *}"; else name_part="$option_value"; fi; name_lower=$(echo "$name_part" | tr '[:upper:]' '[:lower:]'); [[ "$name_lower" == *"$filter_lower"* ]] && eval "$out_name+=(\"$i\")"; done
}
export -f ui_filter_prompt ui_filter_apply
