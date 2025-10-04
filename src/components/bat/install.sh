#!/usr/bin/env bash
set -euo pipefail
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log
if ! command -v bat >/dev/null 2>&1; then
	if command -v brew >/dev/null 2>&1; then brew install bat || true; elif command -v apt-get >/dev/null 2>&1; then sudo apt-get update -y && sudo apt-get install -y bat || true; fi
else log_info "bat present"; fi
