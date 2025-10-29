#!/usr/bin/env bash
# strings/strings.sh - loader for segmented string utilities
[[ -n "${STRINGS_LOADED:-}" ]] && return 0
readonly STRINGS_LOADED=1
STRINGS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=./basic.sh
source "${STRINGS_DIR}/basic.sh"
# shellcheck source=./case.sh
source "${STRINGS_DIR}/case.sh"
# shellcheck source=./predicates.sh
source "${STRINGS_DIR}/predicates.sh"
# shellcheck source=./split.sh
source "${STRINGS_DIR}/split.sh"
# shellcheck source=./replace.sh
source "${STRINGS_DIR}/replace.sh"
# shellcheck source=./format.sh
source "${STRINGS_DIR}/format.sh"
unset STRINGS_DIR
