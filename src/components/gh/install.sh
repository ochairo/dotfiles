#!/usr/bin/env bash
set -euo pipefail
# Component: gh (GitHub CLI)
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log

have() { command -v "$1" >/dev/null 2>&1; }

install_mac() {
	if have brew; then
		if ! brew list gh >/dev/null 2>&1; then
			log_info "Installing gh via Homebrew"
			brew install gh || log_warn "brew install gh failed"
		else
			log_info "gh already installed (brew)"
		fi
	else
		log_warn "Homebrew not found; skipping gh install"
	fi
}

install_linux() {
	if have apt-get; then
		if ! dpkg -s gh >/dev/null 2>&1; then
			log_info "Installing gh via apt-get (GitHub CLI upstream repo recommended for latest)"
			sudo apt-get update -y || true
			sudo apt-get install -y gh || log_warn "apt-get install gh failed (consider official repo)"
		else
			log_info "gh already installed (dpkg)"
		fi
	elif have dnf; then
		if ! rpm -q gh >/dev/null 2>&1; then
			log_info "Installing gh via dnf"
			sudo dnf install -y gh || log_warn "dnf install gh failed"
		else
			log_info "gh already installed (rpm)"
		fi
	elif have pacman; then
		if ! pacman -Qi gh >/dev/null 2>&1; then
			log_info "Installing gh via pacman"
			sudo pacman -Sy --noconfirm gh || log_warn "pacman install gh failed"
		else
			log_info "gh already installed (pacman)"
		fi
	else
		if have gh; then
			log_info "gh present via unknown manager"
		else
			log_warn "No supported package manager found; manual install required for gh"
		fi
	fi
}

main() {
	local os
	os=$(uname -s 2>/dev/null || echo Unknown)
	case $os in
	Darwin) install_mac ;;
	Linux) install_linux ;;
	*) log_warn "Unsupported OS $os; assuming gh present" ;;
	esac
	if have gh; then
		log_info "gh version: $(gh --version 2>/dev/null | head -1)"
	fi
}

main "$@"
