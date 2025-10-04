#!/usr/bin/env bash
set -euo pipefail
ROOT="${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
# shellcheck disable=SC1091
source "$ROOT/core/bootstrap.sh"
core_require log

OS_NAME=$(uname -s 2>/dev/null || echo Unknown)

if ! command -v tldr >/dev/null 2>&1; then
	if [[ $OS_NAME == Darwin* ]]; then
		if command -v brew >/dev/null 2>&1; then
			log_info "Installing tealdeer via Homebrew (macOS)"
			if ! brew install tealdeer >/dev/null 2>&1; then
				log_warn "brew install tealdeer failed; attempting brew upgrade"
				brew upgrade tealdeer >/dev/null 2>&1 || true
			fi
		else
			log_warn "Homebrew not found on macOS; cannot install tealdeer automatically."
		fi
	else
		# Non-macOS: try native package managers in order: apt-get -> dnf -> pacman
		if ! command -v tldr >/dev/null 2>&1; then
			if command -v apt-get >/dev/null 2>&1; then
				log_info "Installing tealdeer via apt-get (Linux)"
				sudo apt-get update -y >/dev/null 2>&1 || log_warn "apt-get update failed (continuing)"
				sudo apt-get install -y tealdeer >/dev/null 2>&1 || log_warn "apt-get install tealdeer failed"
			elif command -v dnf >/dev/null 2>&1; then
				log_info "Installing tealdeer via dnf (Linux)"
				sudo dnf install -y tealdeer >/dev/null 2>&1 || log_warn "dnf install tealdeer failed"
			elif command -v pacman >/dev/null 2>&1; then
				log_info "Installing tealdeer via pacman (Linux)"
				sudo pacman -Sy --noconfirm tealdeer >/dev/null 2>&1 || log_warn "pacman install tealdeer failed"
			else
				log_warn "No supported package manager (apt-get, dnf, pacman) found for tealdeer."
			fi
		fi
	fi
fi

if command -v tldr >/dev/null 2>&1; then
	(tldr --update >/dev/null 2>&1 &)
	# Show resolved path & version for diagnostics
	log_info "tealdeer (tldr) ready: $(command -v tldr) version: $(tldr --version 2>/dev/null | head -1)"
else
	log_error "tealdeer not available after install attempts (brew/apt-get/dnf/pacman)."
	exit 1
fi
