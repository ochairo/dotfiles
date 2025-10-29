#!/usr/bin/env bash
# wizard/wizard.sh - Loader for wizard orchestration (selection flow)

[[ -n ${DOTFILES_WIZARD_LOADED:-} ]] && return 0
readonly DOTFILES_WIZARD_LOADED=1

WIZARD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# shellcheck source=/dev/null
source "${WIZARD_DIR}/welcome.sh"
# shellcheck source=/dev/null
source "${WIZARD_DIR}/categories.sh"
# shellcheck source=/dev/null
source "${WIZARD_DIR}/select.sh"
# shellcheck source=/dev/null
source "${WIZARD_DIR}/custom.sh"
# shellcheck source=/dev/null
source "${WIZARD_DIR}/confirm.sh"
# shellcheck source=/dev/null
source "${WIZARD_DIR}/validate.sh"
# shellcheck source=/dev/null
source "${WIZARD_DIR}/selection_state.sh"
# shellcheck source=/dev/null
source "${WIZARD_DIR}/complete.sh"

wizard_functions_loaded() {
  local count=0 f
  for f in wizard_welcome wizard_categories wizard_select wizard_custom wizard_confirm wizard_validate wizard_selection_state wizard_complete; do
    declare -F "$f" >/dev/null 2>&1 && ((count++))
  done
  echo "$count"
}

export -f wizard_functions_loaded
