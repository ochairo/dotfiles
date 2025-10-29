#!/usr/bin/env bash
# parallel/parallel.sh - Loader for parallel execution utilities

[[ -n "${PARALLEL_MODULE_LOADED:-}" ]] && return 0
readonly PARALLEL_MODULE_LOADED=1

# Default workers if not set
: "${PARALLEL_WORKERS:=4}"

PARALLEL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# shellcheck source=/dev/null
source "${PARALLEL_DIR}/execute.sh"
# shellcheck source=/dev/null
source "${PARALLEL_DIR}/map.sh"
# shellcheck source=/dev/null
source "${PARALLEL_DIR}/foreach.sh"
# shellcheck source=/dev/null
source "${PARALLEL_DIR}/run.sh"
# shellcheck source=/dev/null
source "${PARALLEL_DIR}/workers.sh"
