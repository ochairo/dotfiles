#!/usr/bin/env bash
# errors.sh - Error handling utilities
# Reusable across any shell script project

# Prevent double loading
[[ -n "${ERRORS_LOADED:-}" ]] && return 0
readonly ERRORS_LOADED=1

# Global error context stack
declare -a ERROR_CONTEXT_STACK=()

# Exit with error code and message
error_exit() {
    local exit_code="${1:-$EXIT_ERROR}"
    shift
    local message="$*"

    if [[ -n "$message" ]]; then
        msg_error "$message"
    fi

    error_trace
    exit "$exit_code"
}

# Log error to stderr without exiting
error_log() {
    local message="$*"
    msg_error "$message" >&2
}

# Show error stack trace
error_trace() {
    local frame=0
    local func line file

    msg_error "Call stack:"

    while read -r func line file < <(caller $frame 2>/dev/null || echo ""); do
        [[ -z "$func" ]] && break

        # Skip this function and the error handler
        if [[ "$func" != "error_trace" && "$func" != "error_handler" && "$func" != "error_exit" ]]; then
            msg_error "  at $func() [$file:$line]"
        fi

        ((frame++))
        [[ $frame -gt 20 ]] && break  # Prevent infinite loops
    done

    # Show error context if available
    if [[ ${#ERROR_CONTEXT_STACK[@]} -gt 0 ]]; then
        msg_error "Context:"
        local context
        for context in "${ERROR_CONTEXT_STACK[@]}"; do
            msg_error "  $context"
        done
    fi
}

# Set up error handler trap
error_handler() {
    local exit_code=$?
    local line_number="${1:-}"

    [[ $exit_code -eq 0 ]] && return 0

    msg_error "Script failed with exit code $exit_code"
    [[ -n "$line_number" ]] && msg_error "Error occurred at line $line_number"

    error_trace
    exit "$exit_code"
}

# Add context information to error reporting
error_context() {
    local context="$*"
    ERROR_CONTEXT_STACK+=("$context")
}

# Remove last context from stack
error_context_pop() {
    if [[ ${#ERROR_CONTEXT_STACK[@]} -gt 0 ]]; then
        unset 'ERROR_CONTEXT_STACK[-1]'
    fi
}

# Clear all error context
error_context_clear() {
    ERROR_CONTEXT_STACK=()
}

# Set up error trapping for current script
error_trap_setup() {
    set -eE  # Exit on error, including in functions and subshells
    trap 'error_handler $LINENO' ERR
    trap 'error_context_clear' EXIT
}

# Disable error trapping
error_trap_disable() {
    set +eE
    trap - ERR EXIT
}

# Check if last command succeeded
error_check() {
    local exit_code=$?
    local message="${1:-Command failed}"

    if [[ $exit_code -ne 0 ]]; then
        error_log "$message (exit code: $exit_code)"
        return $exit_code
    fi

    return 0
}

# Run command with error handling
error_safe() {
    local context="$1"
    shift

    error_context "$context"

    if ! "$@"; then
        local exit_code=$?
        error_log "Failed: $context"
        error_context_pop
        return $exit_code
    fi

    error_context_pop
    return 0
}

# Validate required variables are set
error_require_vars() {
    local var_name
    local missing_vars=()

    for var_name in "$@"; do
        if [[ -z "${!var_name:-}" ]]; then
            missing_vars+=("$var_name")
        fi
    done

    if [[ ${#missing_vars[@]} -gt 0 ]]; then
        error_exit "$EXIT_USAGE" "Required variables not set: ${missing_vars[*]}"
    fi
}

# Validate required commands are available
error_require_commands() {
    local cmd_name
    local missing_commands=()

    for cmd_name in "$@"; do
        if ! command -v "$cmd_name" >/dev/null 2>&1; then
            missing_commands+=("$cmd_name")
        fi
    done

    if [[ ${#missing_commands[@]} -gt 0 ]]; then
        error_exit "$EXIT_ERROR" "Required commands not found: ${missing_commands[*]}"
    fi
}

# Show warning without stopping execution
error_warn() {
    local message="$*"
    msg_warn "$message"
}

# Assert condition is true
error_assert() {
    local condition="$1"
    shift
    local message="${*:-Assertion failed}"

    if ! eval "$condition"; then
        error_exit "$EXIT_ERROR" "Assertion failed: $message"
    fi
}

# Try to recover from error
error_try() {
    local attempts="${1:-3}"
    local delay="${2:-1}"
    shift 2
    local cmd=("$@")

    local attempt=1
    while [[ $attempt -le $attempts ]]; do
        if "${cmd[@]}"; then
            return 0
        fi

        if [[ $attempt -lt $attempts ]]; then
            msg_warn "Attempt $attempt failed, retrying in ${delay}s..."
            sleep "$delay"
        fi

        ((attempt++))
    done

    error_log "All $attempts attempts failed: ${cmd[*]}"
    return 1
}
