#!/usr/bin/env bash
set -euo pipefail

# Component: rustup

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log

component_install() {
	if command -v rustup >/dev/null 2>&1; then
		log_info "rustup already installed"
		return 0
	fi

	log_info "Installing rustup (Rust toolchain installer)"

	if command -v brew >/dev/null 2>&1; then
		# macOS with Homebrew
		brew install rustup-init || return 1
		if command -v rustup-init >/dev/null 2>&1; then
			rustup-init -y || return 1
		fi
	elif command -v apt-get >/dev/null 2>&1; then
		# Ubuntu/Debian - use official installer
		install_rustup_via_script || return 1
	elif command -v dnf >/dev/null 2>&1; then
		# Fedora/RHEL - use official installer
		install_rustup_via_script || return 1
	elif command -v pacman >/dev/null 2>&1; then
		# Arch Linux
		sudo pacman -S --noconfirm rustup || install_rustup_via_script || return 1
		if command -v rustup >/dev/null 2>&1; then
			rustup default stable || return 1
		fi
	else
		install_rustup_via_script || return 1
	fi

	# Verify installation
	if command -v rustup >/dev/null 2>&1; then
		log_info "rustup installed successfully"
		# Ensure stable toolchain is installed
		rustup default stable || return 1
	else
		log_error "rustup installation failed"
		return 1
	fi
}

install_rustup_via_script() {
	if command -v curl >/dev/null 2>&1; then
		log_info "Installing rustup via official install script"
		# Security note: This downloads and executes the official Rust installer from sh.rustup.rs
		# Verify the script source at https://sh.rustup.rs before running
		curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y || return 1

		# Source the environment
		# shellcheck disable=SC1091
		source "$HOME/.cargo/env" || true
	else
		log_error "curl not available for rustup installation"
		return 1
	fi
}

component_install "$@"
