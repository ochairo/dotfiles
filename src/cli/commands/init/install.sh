#!/usr/bin/env bash
# init/install.sh - Run installation

init_run_installation() {
  # Guard PROJECT_ROOT (may be unset under set -u); prefer DOTFILES_ROOT fallback
  if [[ -z "${PROJECT_ROOT:-}" ]]; then
    if [[ -n "${DOTFILES_ROOT:-}" ]]; then
      PROJECT_ROOT="$DOTFILES_ROOT"
    else
      # Derive from this script's location (../../.. from commands/init/)
      local script_dir
      script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)"
      PROJECT_ROOT="$script_dir"
    fi
  fi

  local dry_run="${DRY_RUN:-0}" selection="${INIT_SELECTION:-}" dot_cli="${PROJECT_ROOT}/src/cli/bin/dot"

  msg_blank
  if [[ "$dry_run" == 1 ]]; then msg_info "Starting dry-run installation..."; else msg_info "Starting installation..."; fi
  msg_blank

  if [[ ! -x $dot_cli ]]; then msg_error "CLI entrypoint not found at $dot_cli"; return 1; fi

  if [[ -n "$selection" ]]; then
    # Persist selection so install command picks it up via selection_load
    if declare -f selection_save >/dev/null 2>&1; then
      selection_save "$selection"
    else
      local sel_file="${SELECTION_FILE:-$HOME/.dotfiles.selection}"
      printf '%s\n' "$selection" > "$sel_file"
    fi
  else
    # User chose ALL; force ignoring any saved selection
    export DOT_INSTALL_FORCE_ALL=1
  fi
  "$dot_cli" install "${PASSTHRU[@]}"
}
