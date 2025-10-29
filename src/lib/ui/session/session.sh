#!/usr/bin/env bash
# session/session.sh - Unified UI session lifecycle (Phase 8)
# Responsibilities: enter/exit session, manage traps (resize + cleanup), optional alt screen.
# Single reason to change: lifecycle policy.
# <120 lines target.

[[ -n "${UI_SESSION_MODULE_LOADED:-}" ]] && return 0
readonly UI_SESSION_MODULE_LOADED=1

# ui_session_begin <renderer_fn> [<resize_cb>]
# - renderer_fn: function name that performs a full redraw
# - resize_cb : optional function invoked before renderer on SIGWINCH (e.g., ms_handle_resize)
# Behavior:
#   * If DOT_ALT_SCREEN=1 and stderr is a TTY, enters alt screen.
#   * Hides cursor.
#   * Sets traps for SIGWINCH (if DOTFILES_RESPONSIVE=1) and EXIT/INT/TERM.
#   * Performs initial render via renderer_fn.
ui_session_begin() {
  # Safe parameter extraction under set -u. Second arg optional.
  local renderer_fn="${1:-}" resize_cb="${2:-}"
  [[ -z "$renderer_fn" ]] && msg_error "ui_session_begin: renderer_fn required" && return 1
  if ! declare -F "$renderer_fn" >/dev/null; then
    msg_error "ui_session_begin: unknown renderer '$renderer_fn'" && return 1
  fi
  if [[ -n "$resize_cb" ]]; then
    if ! declare -F "$resize_cb" >/dev/null; then
      msg_warn "ui_session_begin: resize_cb '$resize_cb' not found (ignored)"
      resize_cb=""
    fi
  fi

  UI_SESSION_ALT_ACTIVE=0
  if [[ "${DOT_ALT_SCREEN:-0}" == "1" && -t 2 ]]; then
    if command -v ui_alt_screen_enter >/dev/null 2>&1; then
      ui_alt_screen_enter
      UI_SESSION_ALT_ACTIVE=1
    fi
  fi

  ui_hide_cursor
  UI_SESSION_ACTIVE=1

  # Cleanup trap (EXIT / INT / TERM)
  trap 'ui_session_end' EXIT INT TERM

  # Resize trap only if responsive enabled
  if [[ "${DOTFILES_RESPONSIVE:-0}" == "1" ]]; then
    if [[ -n "$resize_cb" ]]; then
      # shellcheck disable=SC2064
      trap "$resize_cb; $renderer_fn" SIGWINCH
    else
      # shellcheck disable=SC2064
      trap "$renderer_fn" SIGWINCH
    fi
  fi

  # Initial render
  "$renderer_fn"

  if [[ "${DOTFILES_UI_DEBUG:-0}" == "1" ]]; then
    msg_dim "[session] begin renderer=$renderer_fn resize_cb=${resize_cb:-<none>} responsive=${DOTFILES_RESPONSIVE:-0}"
  fi
}

# ui_session_end
# Restores cursor and alt screen, clears traps. Safe to call multiple times.
ui_session_end() {
  # Remove resize trap
  trap - SIGWINCH 2>/dev/null || true
  # Remove exit traps to avoid recursion
  trap - EXIT INT TERM 2>/dev/null || true

  if [[ -n "${UI_SESSION_ACTIVE:-}" ]]; then
    ui_show_cursor 2>/dev/null || true
  fi
  if [[ "${UI_SESSION_ALT_ACTIVE:-0}" == "1" ]]; then
    if command -v ui_alt_screen_leave >/dev/null 2>&1; then
      ui_alt_screen_leave
    fi
    UI_SESSION_ALT_ACTIVE=0
  fi
  unset UI_SESSION_ACTIVE

  if [[ "${DOTFILES_UI_DEBUG:-0}" == "1" ]]; then
    msg_dim "[session] end"
  fi
}

# Compatibility shim: if old ui_session_begin/ui_session_end already exist keep them.
if ! declare -F ui_session_begin >/dev/null; then
  export -f ui_session_begin
fi
if ! declare -F ui_session_end >/dev/null; then
  export -f ui_session_end
fi

export -f ui_session_begin ui_session_end
