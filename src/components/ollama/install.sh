#!/usr/bin/env bash
set -euo pipefail

# Component: ollama

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log

component_install() {
	if command -v ollama >/dev/null 2>&1; then
		log_info "ollama already installed"
		return 0
	fi

	log_info "Installing ollama"

	if command -v brew >/dev/null 2>&1; then
		# macOS with Homebrew
		brew install ollama || return 1
	elif command -v apt-get >/dev/null 2>&1; then
		# Ubuntu/Debian - use install script
		install_ollama_via_script || return 1
	elif command -v dnf >/dev/null 2>&1; then
		# Fedora/RHEL - use install script
		install_ollama_via_script || return 1
	elif command -v pacman >/dev/null 2>&1; then
		# Arch Linux with AUR
		if command -v yay >/dev/null 2>&1; then
			yay -S --noconfirm ollama || install_ollama_via_script || return 1
		else
			install_ollama_via_script || return 1
		fi
	else
		install_ollama_via_script || return 1
	fi

	# Verify installation
	if command -v ollama >/dev/null 2>&1; then
		log_info "ollama installed successfully"
	else
		log_error "ollama installation failed"
		return 1
	fi
}

install_ollama_via_script() {
	if command -v curl >/dev/null 2>&1; then
		log_info "Installing ollama via official install script"
		# Security note: This downloads and executes the official Ollama installer from ollama.com
		# Verify the script source at https://ollama.com/install.sh before running
		curl -fsSL https://ollama.com/install.sh | sh || return 1
	else
		log_error "curl not available for ollama installation"
		return 1
	fi
}

component_install "$@"
