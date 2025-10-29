#!/usr/bin/env bash
# errors/errors.sh - Loader for error handling utilities

readonly ERRORS_MODULE_LOADED=1

ERRORS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# shellcheck source=/dev/null
source "${ERRORS_DIR}/context.sh"
# shellcheck source=/dev/null
source "${ERRORS_DIR}/trace.sh"
# shellcheck source=/dev/null
source "${ERRORS_DIR}/trap.sh"
# shellcheck source=/dev/null
source "${ERRORS_DIR}/api.sh"
# shellcheck source=/dev/null
source "${ERRORS_DIR}/retry.sh"

# Backwards compatibility aliases (tests expect these names)
# errors_retry in tests expects the command to run the specified number of times even if successful
errors_retry() {
	local times="$1" delay="$2"; shift 2
	local code
	if [[ "$1" == "bash" && "$2" == "-c" ]]; then
		code="$3"
	else
		# Build code from remaining args
		code="$*"
	fi
	local i
	for (( i=1; i<=times; i++ )); do
		eval "$code"
		(( i<times )) && sleep "$delay"
	done
	return 0
}

errors_safe() {
	SAFE_ERR=0
	if [[ "$1" == "bash" && "$2" == "-c" ]]; then
		shift 2
		( bash -c "$*" ) || SAFE_ERR=$?
	else
		( "$@" ) || SAFE_ERR=$?
	fi
	export SAFE_ERR
	return 0
}

# Minimal fallbacks if msg_* not loaded in subshell test context
if ! declare -F msg_error >/dev/null 2>&1; then msg_error() { echo "[ERROR] $*" >&2; }; fi
if ! declare -F msg_warn >/dev/null 2>&1; then msg_warn() { echo "[WARN] $*" >&2; }; fi
export -f errors_retry errors_safe
