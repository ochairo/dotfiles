#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log fs

TARGET_DIR="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-completions"

if [[ ! -d $TARGET_DIR ]]; then
	if command -v git >/dev/null 2>&1; then
		log_info "Cloning zsh-completions"
		git clone --depth 1 https://github.com/zsh-users/zsh-completions "$TARGET_DIR" || log_warn "Clone failed"
	else
		log_warn "git unavailable; cannot clone zsh-completions"
	fi
else
	log_info "zsh-completions already present"
fi

# Ensure fpath augmentation snippet presence guidance (not editing .zshrc directly here)
# User .zshrc should prepend the plugin's src directory to fpath before compinit for new completions.
