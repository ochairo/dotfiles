#!/usr/bin/env bash
set -euo pipefail

# Component: fnm

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log

component_install() {
	if command -v fnm >/dev/null 2>&1; then
		log_info "fnm already installed"
		return 0
	fi

	log_info "Installing fnm (Fast Node Manager)"

	if command -v brew >/dev/null 2>&1; then
		# macOS with Homebrew
		brew install fnm || return 1
	elif command -v apt-get >/dev/null 2>&1; then
		# Ubuntu/Debian - fnm not in default repos, use install script
		install_fnm_via_script || return 1
	elif command -v dnf >/dev/null 2>&1; then
		# Fedora/RHEL - use install script
		install_fnm_via_script || return 1
	elif command -v pacman >/dev/null 2>&1; then
		# Arch Linux with AUR
		if command -v yay >/dev/null 2>&1; then
			yay -S --noconfirm fnm-bin || install_fnm_via_script || return 1
		else
			install_fnm_via_script || return 1
		fi
	else
		install_fnm_via_script || return 1
	fi

	# Verify installation
	if command -v fnm >/dev/null 2>&1; then
		log_info "fnm installed successfully"
	else
		log_error "fnm installation failed"
		return 1
	fi
}

install_fnm_via_script() {
	if command -v curl >/dev/null 2>&1; then
		log_info "Installing fnm via official install script"
		# Security note: This downloads and executes the official FNM installer from fnm.vercel.app
		# Verify the script source at https://fnm.vercel.app/install before running
		curl -fsSL https://fnm.vercel.app/install | bash || return 1

		# Add to PATH for current session
		export PATH="$HOME/.local/share/fnm:$PATH"
	else
		log_error "curl not available for fnm installation"
		return 1
	fi
}

component_install "$@"
