#!/usr/bin/env bash
set -euo pipefail

# Component: pyenv

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log

component_install() {
	if command -v pyenv >/dev/null 2>&1; then
		log_info "pyenv already installed"
		return 0
	fi

	log_info "Installing pyenv (Python version manager)"

	if command -v brew >/dev/null 2>&1; then
		# macOS with Homebrew
		brew install pyenv || return 1
	elif command -v apt-get >/dev/null 2>&1; then
		# Ubuntu/Debian - install dependencies first, then pyenv
		install_pyenv_ubuntu || return 1
	elif command -v dnf >/dev/null 2>&1; then
		# Fedora/RHEL - install dependencies first, then pyenv
		install_pyenv_fedora || return 1
	elif command -v pacman >/dev/null 2>&1; then
		# Arch Linux - install dependencies first, then pyenv
		install_pyenv_arch || return 1
	else
		install_pyenv_via_git || return 1
	fi

	# Verify installation
	if command -v pyenv >/dev/null 2>&1 || [[ -d "$HOME/.pyenv" ]]; then
		log_info "pyenv installed successfully"
	else
		log_error "pyenv installation failed"
		return 1
	fi
}

install_pyenv_ubuntu() {
	# Install build dependencies
	sudo apt-get update -y || return 1
	sudo apt-get install -y make build-essential libssl-dev zlib1g-dev \
		libbz2-dev libreadline-dev libsqlite3-dev wget curl llvm \
		libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev \
		libffi-dev liblzma-dev || return 1

	install_pyenv_via_git || return 1
}

install_pyenv_fedora() {
	# Install build dependencies
	sudo dnf groupinstall -y "Development Tools" || return 1
	sudo dnf install -y gcc openssl-devel bzip2-devel libffi-devel \
		zlib-devel readline-devel sqlite-devel xz-devel tk-devel || return 1

	install_pyenv_via_git || return 1
}

install_pyenv_arch() {
	# Install build dependencies
	sudo pacman -S --noconfirm base-devel openssl zlib xz tk || return 1

	install_pyenv_via_git || return 1
}

install_pyenv_via_git() {
	if command -v git >/dev/null 2>&1; then
		log_info "Installing pyenv via git clone"
		git clone https://github.com/pyenv/pyenv.git ~/.pyenv || return 1

		# Add to PATH for current session
		export PATH="$HOME/.pyenv/bin:$PATH"
	else
		log_error "git not available for pyenv installation"
		return 1
	fi
}

component_install "$@"
