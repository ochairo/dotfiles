#!/usr/bin/env bash
# errors/api.sh - Public error utility functions (adapted for test expectations)

error_exit() {
    local exit_code="${1:-$EXIT_ERROR}"; shift || true
    local message="$*"
    [[ -n $message ]] && msg_error "$message"
    error_trace
    exit "$exit_code"
}

error_log() { msg_error "$*" >&2; }

error_check() {
    local ec=$? msg="${1:-Command failed}"; if [[ $ec -ne 0 ]]; then error_log "$msg (exit: $ec)"; return $ec; fi; return 0
}

# Execute command list returning its exit code; preserve parent scope for 'bash -c'
error_safe() {
    local ec
    if [[ "$#" -ge 2 && "$1" == "bash" && "$2" == "-c" ]]; then
        shift 2
        eval "$*"
        ec=$?
    else
        "$@"
        ec=$?
    fi
    return $ec
}

error_require_vars() {
    local missing=() v
    for v in "$@"; do [[ -z ${!v:-} ]] && missing+=("$v"); done
    [[ ${#missing[@]} -gt 0 ]] && error_exit "$EXIT_USAGE" "Required variables not set: ${missing[*]}"
}

error_require_commands() {
    local missing=() c
    for c in "$@"; do command -v "$c" >/dev/null 2>&1 || missing+=("$c"); done
    [[ ${#missing[@]} -gt 0 ]] && error_exit "$EXIT_ERROR" "Required commands not found: ${missing[*]}"
}

error_warn() { msg_warn "$*"; }

error_assert() {
    local condition="$1"; shift; local message="${*:-Assertion failed}"
    eval "$condition" || error_exit "$EXIT_ERROR" "Assertion failed: $message"
}
