#!/usr/bin/env bash
set -euo pipefail

# Component: goenv

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log

component_install() {
	if command -v goenv >/dev/null 2>&1; then
		log_info "goenv already installed"
		return 0
	fi

	log_info "Installing goenv (Go version manager)"

	if command -v brew >/dev/null 2>&1; then
		# macOS with Homebrew
		brew install goenv || return 1
	elif command -v apt-get >/dev/null 2>&1; then
		# Ubuntu/Debian - install via git
		install_goenv_via_git || return 1
	elif command -v dnf >/dev/null 2>&1; then
		# Fedora/RHEL - install via git
		install_goenv_via_git || return 1
	elif command -v pacman >/dev/null 2>&1; then
		# Arch Linux with AUR
		if command -v yay >/dev/null 2>&1; then
			yay -S --noconfirm goenv || install_goenv_via_git || return 1
		else
			install_goenv_via_git || return 1
		fi
	else
		install_goenv_via_git || return 1
	fi

	# Verify installation
	if command -v goenv >/dev/null 2>&1 || [[ -d "$HOME/.goenv" ]]; then
		log_info "goenv installed successfully"
	else
		log_error "goenv installation failed"
		return 1
	fi
}

install_goenv_via_git() {
	if command -v git >/dev/null 2>&1; then
		log_info "Installing goenv via git clone"
		git clone https://github.com/go-nv/goenv.git ~/.goenv || return 1

		# Add to PATH for current session
		export PATH="$HOME/.goenv/bin:$PATH"
	else
		log_error "git not available for goenv installation"
		return 1
	fi
}

component_install "$@"
