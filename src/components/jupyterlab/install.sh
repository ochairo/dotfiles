#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log
if ! command -v jupyter-lab >/dev/null 2>&1; then
	if command -v pipx >/dev/null 2>&1; then pipx install jupyterlab || true; elif command -v brew >/dev/null 2>&1; then brew install jupyterlab || true; fi
else log_info "JupyterLab present"; fi
