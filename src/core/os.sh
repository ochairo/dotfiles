#!/usr/bin/env bash
set -euo pipefail

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/constants.sh"

os_detect() {
	local u
	u=$(uname -s 2>/dev/null || echo unknown)
	case $u in
	Darwin) echo "$OS_MACOS" ;;
	Linux) echo "$OS_LINUX" ;;
	*) echo unknown ;;
	esac
}

os_is_macos() { [[ $(os_detect) == "$OS_MACOS" ]]; }
os_is_linux() { [[ $(os_detect) == "$OS_LINUX" ]]; }
