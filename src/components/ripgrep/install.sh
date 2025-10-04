#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log fs

# Install ripgrep binary
if ! command -v rg >/dev/null 2>&1; then
	if command -v brew >/dev/null 2>&1; then
		brew install ripgrep || true
	elif command -v apt-get >/dev/null 2>&1; then
		sudo apt-get update -y && sudo apt-get install -y ripgrep || true
	fi
else
	log_info "ripgrep present"
fi

# Install config files
fs_symlink_component_files ripgrep
