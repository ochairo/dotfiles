#!/usr/bin/env bash
# zsh post-install script: link .zshrc and .zshenv from repository shell config
set -euo pipefail

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../../.." && pwd)}"

# Load libs (msg_*, fs_symlink, config_resolve_dir)
if [[ -f "${DOTFILES_ROOT}/src/lib/index.sh" ]]; then
  # shellcheck disable=SC1091
  source "${DOTFILES_ROOT}/src/lib/index.sh"
fi

SC_CONFIG_DIR="$(config_resolve_dir shell || true)"
if [[ -z "${SC_CONFIG_DIR}" || ! -d "${SC_CONFIG_DIR}" ]]; then
  msg_error "zsh: shell config directory not found (tried standard paths)"
  msg_dim "Checked: ${DOTFILES_ROOT}/src/configs/shell and variants"
  return 0
fi

msg_info "zsh: linking primary entry points (.zshrc .zshenv)"
for f in .zshrc .zshenv; do
  if [[ -f "${SC_CONFIG_DIR}/$f" ]]; then
    if fs_symlink "${SC_CONFIG_DIR}/$f" "${HOME}/$f" "zsh"; then
      msg_success "Linked $f"
    else
      msg_error "Failed to link $f"
    fi
  else
    msg_warn "Missing $f in repository"
  fi
done
msg_dim "Other helper files (.zsh_aliases, .zsh_functions, etc.) are sourced lazily from repository"
