#!/usr/bin/env bash
set -euo pipefail
# Component: ohmyzsh
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log fs

OMZ_DIR="$HOME/.oh-my-zsh"
OMZ_TEMPLATE=\"${CONFIGS_DIR:-$DOTFILES_ROOT/configs}/.config/shell/.zshrc\"

component_install() {
	if [[ ! -d $OMZ_DIR ]]; then
		if command -v git >/dev/null 2>&1; then
			log_info "Cloning oh-my-zsh"
			git clone --depth 1 https://github.com/ohmyzsh/ohmyzsh.git "$OMZ_DIR" || log_warn "Clone failed"
		else
			log_warn "git unavailable; cannot install oh-my-zsh"
		fi
	else
		log_info "oh-my-zsh already present"
	fi

	# Ensure template exists; if not, create a minimal one
	if [[ ! -f "$OMZ_TEMPLATE" ]]; then
		mkdir -p "$(dirname "$OMZ_TEMPLATE")"
		cat >"$OMZ_TEMPLATE" <<'EOF'
#!/usr/bin/env zsh
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="robbyrussell"
plugins=(git)
if [ -d "$ZSH" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi
EOF
		log_info "Generated default .zshrc template"
	fi
	fs_symlink "$OMZ_TEMPLATE" "$HOME/.zshrc" ohmyzsh
}

component_install "$@"
