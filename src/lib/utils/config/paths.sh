#!/usr/bin/env bash
# paths.sh - configuration path resolution utilities
# Provides config_resolve_dir <name> to locate component configuration directory
# across possible repository layouts.

# Bash 3.2 compatible (avoid associative arrays, ${var,,})

config_resolve_dir() {
  local name="$1"
  if [[ -z "$name" ]]; then
    return 1
  fi
  # Candidate directories in priority order
  local candidates=(
    "${DOTFILES_ROOT}/src/configs/${name}" \
    "${DOTFILES_ROOT}/src/configs/${name#./}"
  )
  local c
  for c in "${candidates[@]}"; do
    if [[ -d "$c" ]]; then
      printf '%s' "$c"
      return 0
    fi
  done
  return 1
}
