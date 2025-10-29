#!/usr/bin/env bash
# homebrew post-install script: initialize environment and perform maintenance
set -euo pipefail

BREW_BIN=""
if [[ -f /opt/homebrew/bin/brew ]]; then
  BREW_BIN="/opt/homebrew/bin/brew"
elif [[ -f /usr/local/bin/brew ]]; then
  BREW_BIN="/usr/local/bin/brew"
fi

if [[ -z "${BREW_BIN}" ]]; then
  msg_error "Homebrew executable not found after installation"
  return 1
fi

# Initialize shell env
# shellcheck disable=SC2046
eval "$("${BREW_BIN}" shellenv)"
msg_success "Homebrew environment initialized"

# Maintenance operations
if "${BREW_BIN}" update >/dev/null 2>&1; then
  msg_dim "brew update complete"
else
  msg_warn "brew update failed"
fi

if "${BREW_BIN}" upgrade >/dev/null 2>&1; then
  msg_dim "brew upgrade complete"
else
  msg_warn "brew upgrade encountered issues"
fi

if "${BREW_BIN}" cleanup >/dev/null 2>&1; then
  msg_dim "brew cleanup complete"
else
  msg_warn "brew cleanup encountered issues"
fi

msg_success "Homebrew post-install maintenance finished"
