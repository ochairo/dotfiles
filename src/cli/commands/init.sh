#!/usr/bin/env bash
# usage: dot init [--no-wizard] [--dry-run] [--repeat]
# summary: Installation entrypoint (interactive wizard by default; use --no-wizard for non-interactive)
# group: core
set -euo pipefail

INIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/init"
# shellcheck source=/dev/null
source "${INIT_DIR}/parse.sh"
# shellcheck source=/dev/null
source "${INIT_DIR}/selection.sh"
# shellcheck source=/dev/null
source "${INIT_DIR}/install.sh"
# shellcheck source=/dev/null
source "${INIT_DIR}/completion.sh"

dot_init_main() {
  init_parse_args "$@"
  init_select_components
  init_run_installation
  init_show_completion
}

dot_init_main "$@"
