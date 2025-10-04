#!/usr/bin/env bash
set -euo pipefail
# Component: neovim
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log fs registry

NVIM_CONFIG_SRC="${CONFIGS_DIR:-$DOTFILES_ROOT/configs}/.config/nvim"

component_install() {
	if command -v nvim >/dev/null 2>&1; then
		log_info "Neovim present"
	else
		# Since directory name = component name = package name, we can use the component name directly
		local component_name="neovim"
		if command -v brew >/dev/null 2>&1; then
			log_info "Installing $component_name via brew"
			brew install "$component_name" || true
		elif command -v apt-get >/dev/null 2>&1; then
			sudo apt-get update -y && sudo apt-get install -y "$component_name" || true
		elif command -v dnf >/dev/null 2>&1; then
			sudo dnf install -y "$component_name" || true
		else
			log_warn "No package manager found for $component_name; skipping binary install"
		fi
	fi

	if [[ -d "$NVIM_CONFIG_SRC" ]]; then
		# Use the generic symlink approach based on component.yml
		fs_symlink_component_files "$component_name"
		log_info "Linked Neovim config"
	else
		log_warn "No Neovim config directory at $NVIM_CONFIG_SRC"
	fi
}

component_install "$@"
