#!/usr/bin/env bash
# core/parallel.sh - minimal worker pool for component installs
set -euo pipefail

source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/log.sh"
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/registry.sh"

: "${DOT_PARALLEL_WORKERS:=4}"

parallel_run_components() {
	# args: <ordered_components...>
	local comps=("$@")
	local pids=()
	local failures=()
	local running=0
	for c in "${comps[@]}"; do
		if ! registry_parallel_safe "$c"; then
			# wait existing jobs then run serialized
			for pid in "${pids[@]}"; do wait "$pid" || failures+=("$pid"); done
			pids=()
			log_debug "[serial] $c"
			if ! _parallel_exec_component "$c"; then failures+=("$c"); fi
			continue
		fi
		while ((running >= DOT_PARALLEL_WORKERS)); do
			if wait -n 2>/dev/null; then running=$((running - 1)); else break; fi
		done
		_parallel_exec_component "$c" &
		pids+=("$!")
		running=$((running + 1))
	done
	for pid in "${pids[@]}"; do wait "$pid" || failures+=("$pid"); done
	[[ ${#failures[@]} -eq 0 ]] || return 1
}

_parallel_exec_component() {
	local comp=$1
	local script="$DOTFILES_ROOT/components/$comp/install.sh"
	if [[ ! -x $script ]]; then
		log_warn "No installer for $comp (skip)"
		return 0
	fi
	(DOTFILES_LOG_LEVEL=${DOTFILES_LOG_LEVEL:-INFO} bash "$script")
}
