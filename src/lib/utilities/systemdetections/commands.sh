#!/usr/bin/env bash
# commands.sh - Command detection and version utilities
# Detect if commands exist and get their versions

# Prevent double loading
[[ -n "${COMMAND_DETECTION_LOADED:-}" ]] && return 0
readonly COMMAND_DETECTION_LOADED=1

# Check if a command exists
# Args: command_name
# Returns: 0 if exists, 1 otherwise
# Example: if cmd_exists "git"; then echo "Git installed"; fi
cmd_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Wait for command to become available
# Args: command_name, timeout_seconds (default: 30)
# Returns: 0 if available, 1 if timeout
# Example: cmd_wait_for "docker" 60
cmd_wait_for() {
    local cmd="${1}"
    local timeout="${2:-30}"
    local elapsed=0

    while ! cmd_exists "$cmd"; do
        if [[ $elapsed -ge $timeout ]]; then
            return 1
        fi
        sleep 1
        ((elapsed++))
    done

    return 0
}

# Check command version
# Args: command_name, version_flag (default: --version)
# Returns: version string
# Example: ver=$(cmd_version "git")
cmd_version() {
    local cmd="${1}"
    local flag="${2:---version}"

    if ! cmd_exists "$cmd"; then
        return 1
    fi

    "$cmd" "$flag" 2>&1 | head -n 1
}

# Check if command supports a specific flag
# Args: command_name, flag
# Returns: 0 if supported, 1 otherwise
# Example: if cmd_supports "git" "--help"; then echo "Supports --help"; fi
cmd_supports() {
    local cmd="${1}"
    local flag="${2}"

    if ! cmd_exists "$cmd"; then
        return 1
    fi

    "$cmd" "$flag" >/dev/null 2>&1
}

# Get command path
# Args: command_name
# Returns: full path to command
# Example: path=$(cmd_path "git")
cmd_path() {
    local cmd="${1}"

    if ! cmd_exists "$cmd"; then
        return 1
    fi

    command -v "$cmd"
}

# Check if multiple commands exist
# Args: command_names...
# Returns: 0 if all exist, 1 if any missing
# Example: if cmd_all_exist "git" "curl" "jq"; then echo "All installed"; fi
cmd_all_exist() {
    local missing=0

    for cmd in "$@"; do
        if ! cmd_exists "$cmd"; then
            missing=1
        fi
    done

    return $missing
}

# Check if any of the commands exist
# Args: command_names...
# Returns: 0 if at least one exists, 1 if none exist
# Example: if cmd_any_exist "wget" "curl"; then echo "Can download"; fi
cmd_any_exist() {
    for cmd in "$@"; do
        if cmd_exists "$cmd"; then
            return 0
        fi
    done

    return 1
}

# Get first available command from list
# Args: command_names...
# Returns: name of first available command
# Example: downloader=$(cmd_first_available "curl" "wget" "fetch")
cmd_first_available() {
    for cmd in "$@"; do
        if cmd_exists "$cmd"; then
            echo "$cmd"
            return 0
        fi
    done

    return 1
}
