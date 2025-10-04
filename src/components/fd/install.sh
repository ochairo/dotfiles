#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log registry

if ! command -v fd >/dev/null 2>&1; then
	if command -v brew >/dev/null 2>&1; then
		local pkg_name="$(registry_get_package_name "fd" "brew")"
		brew install "$pkg_name" || true
	elif command -v apt-get >/dev/null 2>&1; then
		local pkg_name="$(registry_get_package_name "fd" "apt")"
		sudo apt-get update -y && sudo apt-get install -y "$pkg_name" || true
	fi
else
	log_info "fd present"
fi
