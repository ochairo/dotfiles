#!/usr/bin/env bash
set -euo pipefail
# Component: zstd
# Installs zstd (Zstandard) CLI compressor/decompressor.
# Supports macOS (Homebrew) and common Linux package managers.

source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log

have() { command -v "$1" >/dev/null 2>&1; }

install_mac() {
	if have brew; then
		if ! brew list zstd >/dev/null 2>&1; then
			log_info "Installing zstd via Homebrew"
			brew install zstd || log_warn "brew install zstd failed"
		else
			log_info "zstd already installed (brew)"
		fi
	else
		log_warn "Homebrew not found; cannot install zstd automatically"
	fi
}

install_linux() {
	if have apt-get; then
		if ! dpkg -s zstd >/dev/null 2>&1; then
			log_info "Installing zstd via apt-get"
			sudo apt-get update -y || true
			sudo apt-get install -y zstd || log_warn "apt-get install zstd failed"
		else
			log_info "zstd already installed (dpkg)"
		fi
	elif have dnf; then
		if ! rpm -q zstd >/dev/null 2>&1; then
			log_info "Installing zstd via dnf"
			sudo dnf install -y zstd || log_warn "dnf install zstd failed"
		else
			log_info "zstd already installed (rpm)"
		fi
	elif have pacman; then
		if ! pacman -Qi zstd >/dev/null 2>&1; then
			log_info "Installing zstd via pacman"
			sudo pacman -Sy --noconfirm zstd || log_warn "pacman install zstd failed"
		else
			log_info "zstd already installed (pacman)"
		fi
	else
		if have zstd; then
			log_info "zstd present via unknown manager (skipping install)"
		else
			log_warn "No supported package manager found; cannot install zstd automatically"
		fi
	fi
}

main() {
	local uname_s
	uname_s=$(uname -s 2>/dev/null || echo Unknown)
	case $uname_s in
	Darwin) install_mac ;;
	Linux) install_linux ;;
	*) log_warn "Unsupported OS $uname_s; assuming zstd present or manual install required" ;;
	esac

	if ! have zstd; then
		log_warn "zstd not found after attempted install"
		return 0 # Non-critical
	fi

	log_info "zstd version: $(zstd -V 2>/dev/null | head -1)"
}

main "$@"
