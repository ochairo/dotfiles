#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log fs

TARGET_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions"

if [[ ! -d $TARGET_DIR ]]; then
	if command -v git >/dev/null 2>&1; then
		log_info "Cloning zsh-autosuggestions"
		git clone --depth 1 https://github.com/zsh-users/zsh-autosuggestions "$TARGET_DIR" || log_warn "Clone failed"
	else
		log_warn "git unavailable; cannot clone zsh-autosuggestions"
	fi
else
	log_info "zsh-autosuggestions already present"
fi
