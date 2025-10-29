#!/usr/bin/env bash
# options.sh - central option management helpers
# Provides validation, introspection, and lifecycle utilities for DOT_OPT_* flags.
# Bash 3.2+ compatible (no ${var^^}).

# Allowed option names (hyphenated). Extend as new options are introduced.
DOT_OPT_ALLOWED=(
  dry-run
  no-parallel
  json
  strict
  verbose
  debug
  profiling
  dry-run-verbose
  trace
)

# Active option registry (space-delimited names)
DOT_ACTIVE_OPTIONS="${DOT_ACTIVE_OPTIONS:-}"

# Translate a hyphenated option name to its environment variable form.
# dry-run => DOT_OPT_DRY_RUN
# json => DOT_OPT_JSON
# Returns via echo.
dot_opt_var() {
  local name="${1:-}" up
  [[ -z "$name" ]] && return 1
  # Replace hyphens with underscores then uppercase via tr (macOS bash 3.2 compatible)
  up="$(echo "$name" | tr '-' '_' | tr '[:lower:]' '[:upper:]')"
  echo "DOT_OPT_${up}"
}

# Check if an option name is allowed.
dot_opt_allowed() {
  local target="${1:-}" entry
  for entry in "${DOT_OPT_ALLOWED[@]}"; do
    [[ "$entry" == "$target" ]] && return 0
  done
  return 1
}

# Set (activate) an option with optional value (default 1).
dot_opt_set() {
  local name="${1:-}" value="${2:-1}" var
  if ! dot_opt_allowed "$name"; then
    msg_error "Unknown option: $name" 2>/dev/null || echo "Unknown option: $name" >&2
    return 1
  fi
  var="$(dot_opt_var "$name")"
  # shellcheck disable=SC2086
  export "$var"="$value"
  # Append to active list if not already present
  if [[ " $DOT_ACTIVE_OPTIONS " != *" $name "* ]]; then
    DOT_ACTIVE_OPTIONS="${DOT_ACTIVE_OPTIONS:+$DOT_ACTIVE_OPTIONS }$name"
  fi
  export DOT_ACTIVE_OPTIONS
  return 0
}

# Unset (deactivate) an option.
dot_opt_unset() {
  local name="${1:-}" var
  if ! dot_opt_allowed "$name"; then
    return 0  # Silently ignore unknown for unset
  fi
  var="$(dot_opt_var "$name")"
  unset "$var" || true
  # Remove from active list
  if [[ -n "$DOT_ACTIVE_OPTIONS" ]]; then
    # Build new list excluding name
    local new_list="" part
    for part in $DOT_ACTIVE_OPTIONS; do
      [[ "$part" == "$name" ]] && continue
      new_list="${new_list:+$new_list }$part"
    done
    DOT_ACTIVE_OPTIONS="$new_list"
    export DOT_ACTIVE_OPTIONS
  fi
}

# Clear all active options.
dot_opt_clear_all() {
  local part var
  for part in $DOT_ACTIVE_OPTIONS; do
    var="$(dot_opt_var "$part")"
    unset "$var" || true
  done
  DOT_ACTIVE_OPTIONS=""
  export DOT_ACTIVE_OPTIONS
}

# Predicate: is option currently set?
dot_opt_is_set() {
  local name="${1:-}"
  local var
  var="$(dot_opt_var "$name")"
  [[ -n "${!var:-}" ]]
}

# List active options (space-delimited).
dot_opt_list() {
  echo "$DOT_ACTIVE_OPTIONS"
}

# Export key functions for downstream sourced scripts.
export -f dot_opt_var dot_opt_allowed dot_opt_set dot_opt_unset dot_opt_clear_all dot_opt_is_set dot_opt_list
