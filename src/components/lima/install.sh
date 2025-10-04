#!/usr/bin/env bash
set -euo pipefail
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log
if ! command -v limactl >/dev/null 2>&1; then
	if command -v brew >/dev/null 2>&1; then brew install lima || true; fi
else log_info "lima present"; fi
