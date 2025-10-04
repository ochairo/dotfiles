#!/usr/bin/env bash
set -euo pipefail

# Component: rbenv

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log

component_install() {
	if command -v rbenv >/dev/null 2>&1; then
		log_info "rbenv already installed"
		return 0
	fi

	log_info "Installing rbenv (Ruby version manager)"

	if command -v brew >/dev/null 2>&1; then
		# macOS with Homebrew
		brew install rbenv || return 1
	elif command -v apt-get >/dev/null 2>&1; then
		# Ubuntu/Debian - install dependencies first, then rbenv
		install_rbenv_ubuntu || return 1
	elif command -v dnf >/dev/null 2>&1; then
		# Fedora/RHEL - install dependencies first, then rbenv
		install_rbenv_fedora || return 1
	elif command -v pacman >/dev/null 2>&1; then
		# Arch Linux - install dependencies first, then rbenv
		install_rbenv_arch || return 1
	else
		install_rbenv_via_git || return 1
	fi

	# Verify installation
	if command -v rbenv >/dev/null 2>&1 || [[ -d "$HOME/.rbenv" ]]; then
		log_info "rbenv installed successfully"
	else
		log_error "rbenv installation failed"
		return 1
	fi
}

install_rbenv_ubuntu() {
	# Install build dependencies
	sudo apt-get update -y || return 1
	sudo apt-get install -y git curl libssl-dev libreadline-dev zlib1g-dev \
		autoconf bison build-essential libyaml-dev libreadline-dev \
		libncurses5-dev libffi-dev libgdbm-dev || return 1

	install_rbenv_via_git || return 1
}

install_rbenv_fedora() {
	# Install build dependencies
	sudo dnf groupinstall -y "Development Tools" || return 1
	sudo dnf install -y git openssl-devel libyaml-devel libffi-devel \
		readline-devel zlib-devel gdbm-devel ncurses-devel || return 1

	install_rbenv_via_git || return 1
}

install_rbenv_arch() {
	# Install build dependencies
	sudo pacman -S --noconfirm base-devel openssl zlib || return 1

	install_rbenv_via_git || return 1
}

install_rbenv_via_git() {
	if command -v git >/dev/null 2>&1; then
		log_info "Installing rbenv via git clone"
		git clone https://github.com/rbenv/rbenv.git ~/.rbenv || return 1

		# Install ruby-build plugin
		git clone https://github.com/rbenv/ruby-build.git ~/.rbenv/plugins/ruby-build || return 1

		# Add to PATH for current session
		export PATH="$HOME/.rbenv/bin:$PATH"
	else
		log_error "git not available for rbenv installation"
		return 1
	fi
}

component_install "$@"
