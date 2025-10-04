#!/usr/bin/env bash
set -euo pipefail
# Component: podman-compose
# Installs podman-compose; prefers Homebrew, falls back to pipx if available.
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log

have() { command -v "$1" >/dev/null 2>&1; }

install_mac() {
	if have brew; then
		if ! brew list podman-compose >/dev/null 2>&1; then
			log_info "Installing podman-compose via Homebrew"
			brew install podman-compose || log_warn "brew install podman-compose failed"
		else
			log_info "podman-compose already installed (brew)"
		fi
	fi
}

install_linux() {
	# Many distros may not have a native package; fallback to pipx (preferred) or pip.
	if have brew; then
		# Linuxbrew path
		if ! brew list podman-compose >/dev/null 2>&1; then
			log_info "Installing podman-compose via Homebrew (linuxbrew)"
			brew install podman-compose || log_warn "brew install podman-compose failed"
			return
		else
			log_info "podman-compose already installed (brew)"
			return
		fi
	fi
	if have podman-compose; then
		log_info "podman-compose already present"
		return
	fi
	if have pipx; then
		if ! pipx list 2>/dev/null | grep -q podman-compose; then
			log_info "Installing podman-compose via pipx"
			pipx install podman-compose || log_warn "pipx install podman-compose failed"
		else
			log_info "podman-compose already installed (pipx)"
		fi
	elif have pip3; then
		log_info "Installing podman-compose via pip3 (user)"
		pip3 install --user podman-compose || log_warn "pip3 install podman-compose failed"
	else
		log_warn "No installer (brew/pipx/pip) available for podman-compose"
	fi
}

main() {
	local os
	os=$(uname -s 2>/dev/null || echo Unknown)
	case $os in
	Darwin) install_mac ;;
	Linux) install_linux ;;
	*) log_warn "Unsupported OS $os; assuming podman-compose present" ;;
	esac
	if have podman-compose; then
		log_info "podman-compose version: $(podman-compose --version 2>/dev/null || true)"
	fi
}

main "$@"
