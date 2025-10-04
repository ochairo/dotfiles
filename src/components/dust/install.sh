#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log
if ! command -v dust >/dev/null 2>&1; then
	if command -v brew >/dev/null 2>&1; then brew install dust || true; elif command -v cargo >/dev/null 2>&1; then cargo install dust || true; fi
else log_info "dust present"; fi
