#!/usr/bin/env bash
# fzf post-install script: installs shell integration (if available) and links config
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

# Optional shell integration (macOS/Homebrew primarily)
if command -v fzf >/dev/null 2>&1; then
  if command -v brew >/dev/null 2>&1; then
    FZF_INSTALL_SCRIPT="$(brew --prefix)/opt/fzf/install"
    if [[ -x "$FZF_INSTALL_SCRIPT" ]]; then
      "$FZF_INSTALL_SCRIPT" --key-bindings --completion --no-update-rc --no-bash --no-fish || msg_warn "fzf integration script exited non-zero"
      msg_dim "fzf shell integration processed"
    fi
  fi
fi

CONFIG_SOURCE="$(config_resolve_dir fzf || true)"
TARGET_DIR="${HOME}/.config/fzf"
mkdir -p "$TARGET_DIR"

if [[ -n "$CONFIG_SOURCE" && -d "$CONFIG_SOURCE" ]]; then
  if [[ -f "$CONFIG_SOURCE/fzf.zsh" ]]; then
    fs_symlink "$CONFIG_SOURCE/fzf.zsh" "$TARGET_DIR/fzf.zsh" "fzf" || { msg_error "Failed to link fzf.zsh"; return 1; }
    msg_success "fzf configuration linked"
  else
    msg_warn "fzf.zsh not found in $CONFIG_SOURCE"
  fi
else
  msg_warn "fzf config directory not found (checked standard paths)"
fi
