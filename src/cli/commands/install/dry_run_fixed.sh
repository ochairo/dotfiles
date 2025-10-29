#!/usr/bin/env bash
# Revised dry-run implementation without undefined symbol references
set -euo pipefail

install_dry_run() {
  local ordered=("$@")
  # Prefer local DRY_RUN_VERBOSE set by install.sh; fallback to legacy env var if present
  local verbose=${DRY_RUN_VERBOSE:-${DOT_OPT_DRY_RUN_VERBOSE:-0}}
  local count=${#ordered[@]}
  if declare -F msg_info >/dev/null 2>&1; then
    msg_info "Dry run: planned components (${count}): ${ordered[*]}"
  else
    echo "Dry run: planned components (${count}): ${ordered[*]}" >&2
  fi
  if [[ $verbose == 1 ]]; then
    for comp in "${ordered[@]}"; do
      if declare -F msg_dim >/dev/null 2>&1; then msg_dim "Component: $comp"; else echo "Component: $comp" >&2; fi
    done
  fi
}

export -f install_dry_run
