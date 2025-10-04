#!/usr/bin/env bash
set -euo pipefail
# Component: helix
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log fs

component_install() {
	# Install helix binary
	if command -v hx >/dev/null 2>&1; then
		log_info "helix already installed"
	else
		log_info "Installing helix"
		if command -v brew >/dev/null 2>&1; then
			# macOS with Homebrew
			brew install helix || return 1
		elif command -v cargo >/dev/null 2>&1; then
			# Install via cargo
			cargo install --locked helix-term || return 1
		elif command -v apt-get >/dev/null 2>&1; then
			# Ubuntu/Debian - helix might not be in default repos, use cargo as fallback
			if ! sudo apt-get update -y || ! sudo apt-get install -y helix 2>/dev/null; then
				log_info "helix not available via apt, trying cargo..."
				if command -v cargo >/dev/null 2>&1; then
					cargo install --locked helix-term || return 1
				else
					log_warn "Neither apt nor cargo available for helix installation"
					return 1
				fi
			fi
		elif command -v dnf >/dev/null 2>&1; then
			# Fedora/RHEL - helix should be available in newer versions
			if ! sudo dnf install -y helix 2>/dev/null; then
				log_info "helix not available via dnf, trying cargo..."
				if command -v cargo >/dev/null 2>&1; then
					cargo install --locked helix-term || return 1
				else
					log_warn "Neither dnf nor cargo available for helix installation"
					return 1
				fi
			fi
		else
			log_warn "No supported package manager found for helix"
			return 1
		fi
	fi

	# Install config files using the generic approach
	fs_symlink_component_files helix
}

component_install "$@"
