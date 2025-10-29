#!/usr/bin/env bash
# arrays/arrays.sh loader - segmented array utilities (internalized)
[[ -n "${ARRAYS_LOADED:-}" ]] && return 0
readonly ARRAYS_LOADED=1
_arrays_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=./core.sh
source "${_arrays_dir}/core.sh"
# shellcheck source=./mutation.sh
source "${_arrays_dir}/mutation.sh"
# shellcheck source=./slicing.sh
source "${_arrays_dir}/slicing.sh"
# shellcheck source=./setops.sh
source "${_arrays_dir}/setops.sh"
# shellcheck source=./assoc.sh
source "${_arrays_dir}/assoc.sh"
# shellcheck source=./functional.sh
source "${_arrays_dir}/functional.sh"
unset _arrays_dir
