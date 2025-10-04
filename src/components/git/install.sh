#!/usr/bin/env bash
set -euo pipefail

# Component: git

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log os

component_install() {
	if command -v git >/dev/null 2>&1; then
		log_info "git already installed"
		return 0
	fi
	log_info "Installing git"
	if command -v brew >/dev/null 2>&1; then
		brew install git || return 1
	elif command -v apt-get >/dev/null 2>&1; then
		sudo apt-get update -y && sudo apt-get install -y git || return 1
	elif command -v dnf >/dev/null 2>&1; then
		sudo dnf install -y git || return 1
	else
		log_warn "No supported package manager found for git install"
	fi
}

component_install "$@"
