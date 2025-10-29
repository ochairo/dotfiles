#!/usr/bin/env bash
# transactional/transactional.sh loader - segmented transactional modules internalized
[[ -n "${INSTALL_TRANSACTIONAL_LOADED:-}" ]] && return 0
readonly INSTALL_TRANSACTIONAL_LOADED=1
_tx_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "${_tx_dir}/init.sh"
source "${_tx_dir}/lifecycle.sh"
source "${_tx_dir}/staging.sh"
source "${_tx_dir}/apply.sh"
source "${_tx_dir}/execute.sh"
unset _tx_dir
