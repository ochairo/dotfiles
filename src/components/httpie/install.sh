#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log
if ! command -v http >/dev/null 2>&1; then
	if command -v brew >/dev/null 2>&1; then brew install httpie || true; elif command -v pipx >/dev/null 2>&1; then pipx install httpie || true; fi
else log_info "httpie present"; fi
