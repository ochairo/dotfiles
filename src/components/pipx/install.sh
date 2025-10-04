#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log
if ! command -v pipx >/dev/null 2>&1; then
	if command -v brew >/dev/null 2>&1; then brew install pipx || true; fi
	if ! command -v pipx >/dev/null 2>&1 && command -v python3 >/dev/null 2>&1; then
		python3 -m pip install --user pipx || true
		python3 -m pipx ensurepath || true
	fi
else log_info "pipx present"; fi
