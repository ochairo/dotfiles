#!/usr/bin/env bash
# env/config.sh - Prototype configuration ingestion for UI (Phase: onboarding prep)
# Reads simple key: value pairs; maps to DOTFILES_* environment vars then refreshes env snapshot.
# <120 lines. Single responsibility: config ingestion + mapping.

[[ -n "${UI_ENV_CONFIG_LOADED:-}" ]] && return 0
readonly UI_ENV_CONFIG_LOADED=1

# ui_config_load <file>
# Supported keys:
#   min_rows: <int>
#   responsive: true|false
#   debug: true|false
# Lines: key: value ; comments (# ...) ignored; blank lines ignored.
# After load, updates DOTFILES_* and reloads env/env.sh snapshot variables.
ui_config_load() {
  local file="$1"
  [[ -z "$file" ]] && msg_error "ui_config_load: file required" && return 1
  [[ ! -f "$file" ]] && msg_error "ui_config_load: file not found: $file" && return 1
  local line key val
  while IFS= read -r line || [[ -n "$line" ]]; do
    # Ignore blank & comment lines
    [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
    # Preserve full line (avoid premature trimming that broke value parsing)
    if [[ "$line" =~ ^([^:]+):[[:space:]]*(.*)$ ]]; then
      key="${BASH_REMATCH[1]}"; val="${BASH_REMATCH[2]}"
      # Trim trailing spaces from val
      val="$(echo "$val" | sed 's/[[:space:]]*$//')"
      key="$(echo "$key" | tr 'A-Z' 'a-z')"
      case "$key" in
        min_rows)
          if [[ "$val" =~ ^[0-9]+$ ]]; then
            DOTFILES_MIN_CONTENT_ROWS="$val"
            export DOTFILES_MIN_CONTENT_ROWS
          else
            msg_warn "invalid min_rows: $val"
          fi
          ;;
        responsive)
          if [[ "$val" =~ ^(true|1)$ ]]; then DOTFILES_RESPONSIVE=1; else DOTFILES_RESPONSIVE=0; fi
          export DOTFILES_RESPONSIVE
          ;;
        debug)
          if [[ "$val" =~ ^(true|1)$ ]]; then DOTFILES_UI_DEBUG=1; else DOTFILES_UI_DEBUG=0; fi
          export DOTFILES_UI_DEBUG
          ;;
        *) msg_dim "[config] ignored key: $key" ;;
      esac
    fi
  done < "$file"
  # Refresh snapshot variables if env/env.sh available
  if declare -F ui_env_min_rows >/dev/null; then
    # Recompute snapshots
    UI_ENV_MIN_ROWS="$(ui_env_min_rows)"
    UI_ENV_RESPONSIVE="$(ui_env_responsive)"
    UI_ENV_DEBUG="$(ui_env_debug)"
    export UI_ENV_MIN_ROWS UI_ENV_RESPONSIVE UI_ENV_DEBUG
  fi
  if [[ "${DOTFILES_UI_DEBUG:-0}" == "1" ]]; then
    msg_dim "[config] applied from $file (min_rows=$UI_ENV_MIN_ROWS responsive=$UI_ENV_RESPONSIVE debug=$UI_ENV_DEBUG)"
  fi
}

export -f ui_config_load
