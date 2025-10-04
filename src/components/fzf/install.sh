#!/usr/bin/env bash
set -euo pipefail
# Component: fzf
# Installs fzf and sets up key bindings / completion non-interactively.
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log

have() { command -v "$1" >/dev/null 2>&1; }

install_mac() {
	if have brew; then
		if ! brew list fzf >/dev/null 2>&1; then
			log_info "Installing fzf via Homebrew"
			brew install fzf || log_warn "brew install fzf failed"
		else
			log_info "fzf already installed (brew)"
		fi
		# Run fzf install script for keybindings & completion if not already placed
		local opt_dir
		opt_dir=$(brew --prefix fzf 2>/dev/null || true)
		if [[ -n $opt_dir && -d $opt_dir ]]; then
			if [[ ! -f $opt_dir/shell/key-bindings.zsh ]]; then
				log_warn "fzf shell assets missing; unexpected layout"
				return 0
			fi
			# We do NOT auto-source here; user can add to .zshrc if desired.
		fi
	else
		log_warn "Homebrew not found; skipping fzf install (macOS)"
	fi
}

install_linux() {
	if have apt-get; then
		if ! dpkg -s fzf >/dev/null 2>&1; then
			log_info "Installing fzf via apt-get"
			sudo apt-get update -y || true
			sudo apt-get install -y fzf || log_warn "apt-get install fzf failed"
		else
			log_info "fzf already installed (dpkg)"
		fi
	elif have dnf; then
		if ! rpm -q fzf >/dev/null 2>&1; then
			log_info "Installing fzf via dnf"
			sudo dnf install -y fzf || log_warn "dnf install fzf failed"
		else
			log_info "fzf already installed (rpm)"
		fi
	elif have pacman; then
		if ! pacman -Qi fzf >/dev/null 2>&1; then
			log_info "Installing fzf via pacman"
			sudo pacman -Sy --noconfirm fzf || log_warn "pacman install fzf failed"
		else
			log_info "fzf already installed (pacman)"
		fi
	else
		if have fzf; then
			log_info "fzf present via unknown manager"
		else
			log_warn "No supported package manager found; manual install required for fzf"
		fi
	fi
}

main() {
	local os
	os=$(uname -s 2>/dev/null || echo Unknown)
	case $os in
	Darwin) install_mac ;;
	Linux) install_linux ;;
	*) log_warn "Unsupported OS $os; assuming fzf present" ;;
	esac

	if have fzf; then
		log_info "fzf version: $(fzf --version 2>/dev/null || true)"
	fi
}

main "$@"
