#!/usr/bin/env bash
# WezTerm post-install script: links configuration directory
set -euo pipefail

# shellcheck source=/dev/null
if [[ -f "${DOTFILES_ROOT}/src/lib/utils/files/fs.sh" ]]; then
  # shellcheck disable=SC1091
  source "${DOTFILES_ROOT}/src/lib/utils/files/fs.sh"
elif [[ -f "${DOTFILES_ROOT}/src/core/fs.sh" ]]; then
  # shellcheck disable=SC1091
  source "${DOTFILES_ROOT}/src/core/fs.sh"
fi
[[ -f "${DOTFILES_ROOT}/src/lib/index.sh" ]] && source "${DOTFILES_ROOT}/src/lib/index.sh"

CONFIG_SOURCE="$(config_resolve_dir wezterm || true)"
TARGET_DIR="${HOME}/.config/wezterm"

if [[ -n "$CONFIG_SOURCE" && -d "$CONFIG_SOURCE" ]]; then
  fs_symlink "$CONFIG_SOURCE" "$TARGET_DIR" "wezterm" || { msg_error "Failed to link WezTerm config"; return 1; }
  msg_success "WezTerm configuration linked"
else
  msg_warn "WezTerm config directory not found (checked standard paths)"
fi
