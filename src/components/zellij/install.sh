#!/usr/bin/env bash
set -euo pipefail
# Component: zellij
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log fs

component_install() {
	if ! command -v zellij >/dev/null 2>&1; then
		if command -v brew >/dev/null 2>&1; then
			log_info "Installing zellij via Homebrew"
			brew install zellij || true
		elif command -v cargo >/dev/null 2>&1; then
			log_info "Installing zellij via cargo"
			cargo install zellij || true
		elif command -v apt-get >/dev/null 2>&1; then
			log_warn "No native apt recipe implemented for zellij"
		fi
	else
		log_info "zellij present"
	fi
	# Install config
	fs_symlink_component_files zellij
}

component_install "$@"
