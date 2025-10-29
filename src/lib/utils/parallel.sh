#!/usr/bin/env bash
# legacy stub: parallel.sh now segmented under parallel/parallel.sh
[[ -n "${PARALLEL_STUB_LOADED:-}" ]] && return 0
readonly PARALLEL_STUB_LOADED=1
PARALLEL_MODULE_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=/dev/null
source "${PARALLEL_MODULE_ROOT}/parallel/parallel.sh"
