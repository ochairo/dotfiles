#!/usr/bin/env bash
# core/parallel.sh - minimal worker pool for component installs
set -euo pipefail

source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/log.sh"
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/registry.sh"

: "${DOT_PARALLEL_WORKERS:=4}"
