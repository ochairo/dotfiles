#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log
if ! command -v uv >/dev/null 2>&1; then
	if command -v brew >/dev/null 2>&1; then brew install uv || true; else log_warn "uv install not implemented for this platform"; fi
else log_info "uv present"; fi
