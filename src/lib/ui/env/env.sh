#!/usr/bin/env bash
# env/env.sh - Centralized environment configuration & overrides (Phase 9)
# Responsibilities: resolve and expose UI environment-driven settings.
# Single reason to change: environment variable policy.
# <120 lines.

[[ -n "${UI_ENV_LOADED:-}" ]] && return 0
readonly UI_ENV_LOADED=1

# Resolve minimum content rows
ui_env_min_rows() {
  local default_min=${UI_MIN_DEFAULT_ROWS:-3}
  local legacy_min=${UI_MIN_PAGE_ROWS:-$default_min}
  local raw=${DOTFILES_MIN_CONTENT_ROWS:-$legacy_min}
  [[ ! $raw =~ ^[0-9]+$ ]] && raw=$default_min
  echo "$raw"
}

# Responsive mode? (resize trapping)
ui_env_responsive() {
  [[ "${DOTFILES_RESPONSIVE:-0}" == "1" ]] && echo 1 || echo 0
}

# Debug mode? (extra diagnostic lines)
ui_env_debug() {
  [[ "${DOTFILES_UI_DEBUG:-0}" == "1" ]] && echo 1 || echo 0
}

# Export evaluated constants for convenience (read-only snapshot)
UI_ENV_MIN_ROWS=$(ui_env_min_rows)
UI_ENV_RESPONSIVE=$(ui_env_responsive)
UI_ENV_DEBUG=$(ui_env_debug)

export UI_ENV_MIN_ROWS UI_ENV_RESPONSIVE UI_ENV_DEBUG
export -f ui_env_min_rows ui_env_responsive ui_env_debug
