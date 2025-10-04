#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log

if ! command -v podman >/dev/null 2>&1; then
	if command -v brew >/dev/null 2>&1; then
		log_info "Installing podman via brew"
		brew install podman || true
	elif command -v apt-get >/dev/null 2>&1; then
		sudo apt-get update -y && sudo apt-get install -y podman || true
	fi
else
	log_info "podman present"
fi
