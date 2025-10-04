#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log
if ! command -v huggingface-cli >/dev/null 2>&1; then
	if command -v pipx >/dev/null 2>&1; then pipx install huggingface_hub || true; else log_warn "pipx not available for huggingface_hub"; fi
else log_info "huggingface-cli present"; fi
