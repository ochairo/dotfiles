#!/usr/bin/env bash
# errors/trap.sh - Error trap setup / disable handlers

error_handler() {
    local exit_code=$? line_number="${1:-}"; [[ $exit_code -eq 0 ]] && return 0
    msg_error "Script failed with exit code $exit_code"
    [[ -n $line_number ]] && msg_error "Error occurred at line $line_number"
    error_trace
    exit "$exit_code"
}

error_trap_setup() { set -eE; trap 'error_handler $LINENO' ERR; trap 'error_context_clear' EXIT; }
error_trap_disable() { set +eE; trap - ERR EXIT; }
