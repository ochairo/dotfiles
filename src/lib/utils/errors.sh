#!/usr/bin/env bash
# legacy stub: errors.sh now segmented under errors/
[[ -n "${ERRORS_STUB_LOADED:-}" ]] && return 0
readonly ERRORS_STUB_LOADED=1
ERRORS_MODULE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=/dev/null
source "${ERRORS_MODULE_ROOT}/errors/errors.sh"
