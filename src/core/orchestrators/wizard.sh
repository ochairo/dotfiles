#!/usr/bin/env bash
# wizard.sh - Loader for interactive installation wizard functions (test-compatible)

# Set guard variable first for test visibility
DOTFILES_WIZARD_LOADED=1
if [[ -n "${DOTFILES_WIZARD_ALREADY_LOADED:-}" ]]; then
  return 0
fi
DOTFILES_WIZARD_ALREADY_LOADED=1

WIZARD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)/wizard"

# shellcheck source=/dev/null
source "${WIZARD_DIR}/welcome.sh"
# shellcheck source=/dev/null
source "${WIZARD_DIR}/select.sh"
# shellcheck source=/dev/null
source "${WIZARD_DIR}/custom.sh"
# shellcheck source=/dev/null
source "${WIZARD_DIR}/validate.sh"
# shellcheck source=/dev/null
source "${WIZARD_DIR}/confirm.sh"
# shellcheck source=/dev/null
source "${WIZARD_DIR}/complete.sh"
# shellcheck source=/dev/null
source "${WIZARD_DIR}/categories.sh"
# shellcheck source=/dev/null
source "${WIZARD_DIR}/selection_state.sh"

# Backwards-compatible function names expected by tests
wizard_select() { presets_select "$@"; }
wizard_confirm() { presets_confirm_installation "$@"; }

export -f wizard_select wizard_confirm
