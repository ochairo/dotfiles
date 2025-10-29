#!/usr/bin/env bash
# validation/validation.sh - Loader for validation utilities

[[ -n "${VALIDATION_MODULE_LOADED:-}" ]] && return 0
readonly VALIDATION_MODULE_LOADED=1

VALIDATION_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# shellcheck source=/dev/null
source "${VALIDATION_DIR}/files.sh"
# shellcheck source=/dev/null
source "${VALIDATION_DIR}/formats.sh"
# shellcheck source=/dev/null
source "${VALIDATION_DIR}/numbers.sh"
# shellcheck source=/dev/null
source "${VALIDATION_DIR}/strings.sh"
# shellcheck source=/dev/null
source "${VALIDATION_DIR}/choice.sh"
