#!/usr/bin/env bash
# retry.sh - Generic retry utilities with exponential backoff
# Can wrap any command or function

# Prevent double loading
[[ -n "${RETRY_UTILS_LOADED:-}" ]] && return 0
readonly RETRY_UTILS_LOADED=1

# Retry a command/function with exponential backoff
# Args: max_attempts, command [args...]
# Returns: exit code of last attempt
# Example: retry 3 curl -fsSL https://example.com
# Example: retry 5 download_file "url" "path"
# Example: retry 3 some_function arg1 arg2
retry() {
    local max_attempts="${1}"
    shift
    local attempt=1
    local delay=1

    while [[ $attempt -le $max_attempts ]]; do
        if "$@"; then
            return 0
        fi

        if [[ $attempt -lt $max_attempts ]]; then
            sleep $delay
            delay=$((delay * 2))  # Exponential backoff: 1s, 2s, 4s, 8s...
        fi

        ((attempt++))
    done

    return 1
}

# Retry with custom backoff strategy
# Args: max_attempts, initial_delay, backoff_multiplier, command [args...]
# Returns: exit code of last attempt
# Example: retry_with_backoff 5 2 3 curl -fsSL https://example.com
retry_with_backoff() {
    local max_attempts="${1}"
    local initial_delay="${2}"
    local multiplier="${3}"
    shift 3
    local attempt=1
    local delay=$initial_delay

    while [[ $attempt -le $max_attempts ]]; do
        if "$@"; then
            return 0
        fi

        if [[ $attempt -lt $max_attempts ]]; then
            sleep "$delay"
            delay=$((delay * multiplier))
        fi

        ((attempt++))
    done

    return 1
}

# Retry with fixed delay (no backoff)
# Args: max_attempts, delay_seconds, command [args...]
# Returns: exit code of last attempt
# Example: retry_fixed 3 5 slow_command
retry_fixed() {
    local max_attempts="${1}"
    local delay="${2}"
    shift 2
    local attempt=1

    while [[ $attempt -le $max_attempts ]]; do
        if "$@"; then
            return 0
        fi

        if [[ $attempt -lt $max_attempts ]]; then
            sleep "$delay"
        fi

        ((attempt++))
    done

    return 1
}

# Retry until success or timeout
# Args: timeout_seconds, check_interval, command [args...]
# Returns: 0 if success, 1 if timeout
# Example: retry_until 60 2 check_service_up
retry_until() {
    local timeout="${1}"
    local interval="${2}"
    shift 2
    local elapsed=0

    while [[ $elapsed -lt $timeout ]]; do
        if "$@"; then
            return 0
        fi

        sleep "$interval"
        elapsed=$((elapsed + interval))
    done

    return 1
}
