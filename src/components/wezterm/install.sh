#!/usr/bin/env bash
set -euo pipefail
# Component: wezterm
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log fs

component_install() {
	if ! command -v wezterm >/dev/null 2>&1; then
		if command -v brew >/dev/null 2>&1; then
			log_info "Installing wezterm via Homebrew"
			brew install --cask wezterm || true
		elif command -v apt-get >/dev/null 2>&1; then
			log_warn "WezTerm apt package not standard; skipping binary install"
		fi
	else
		log_info "WezTerm present"
	fi
	# Install config
	fs_symlink_component_files wezterm
}

component_install "$@"
