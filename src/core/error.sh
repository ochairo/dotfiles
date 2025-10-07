#!/usr/bin/env bash
# core/error.sh - Standardized error handling and recovery patterns
set -euo pipefail

source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/constants.sh"
source "$DOTFILES_ROOT/core/log.sh"

# =============================================================================
# ERROR CODES AND DEFINITIONS
# =============================================================================

# Standard exit codes
readonly ERROR_SUCCESS=0
readonly ERROR_GENERAL=1
readonly ERROR_MISUSE=2
readonly ERROR_COMPONENT_NOT_FOUND=10
readonly ERROR_DEPENDENCY_MISSING=11
readonly ERROR_DEPENDENCY_CYCLE=12
readonly ERROR_VALIDATION_FAILED=20
readonly ERROR_INSTALLATION_FAILED=30
readonly ERROR_NETWORK_ERROR=40
readonly ERROR_PERMISSION_DENIED=50
readonly ERROR_DISK_FULL=51
readonly ERROR_USER_CANCELLED=60

# Export error codes
export ERROR_SUCCESS ERROR_GENERAL ERROR_MISUSE
export ERROR_COMPONENT_NOT_FOUND ERROR_DEPENDENCY_MISSING ERROR_DEPENDENCY_CYCLE
export ERROR_VALIDATION_FAILED ERROR_INSTALLATION_FAILED
export ERROR_NETWORK_ERROR ERROR_PERMISSION_DENIED ERROR_DISK_FULL
export ERROR_USER_CANCELLED

# =============================================================================
# ERROR HANDLING FUNCTIONS
# =============================================================================

# Enhanced error reporting with structured information
error_report() {
    local error_code="$1"
    local error_message="$2"
    local component="${3:-}"
    local suggestion="${4:-}"
    local details="${5:-}"

    log_error "Error $error_code: $error_message"

    if [[ -n "$component" ]]; then
        log_error "Component: $component"
    fi

    if [[ -n "$details" ]]; then
        log_error "Details: $details"
    fi

    if [[ -n "$suggestion" ]]; then
        log_info "Suggestion: $suggestion"
    fi

    # Add specific guidance based on error code
    case "$error_code" in
        "$ERROR_COMPONENT_NOT_FOUND")
            log_info "Available components: $(registry_list_components | tr '\n' ' ' || echo 'Unable to list')"
            ;;
        "$ERROR_DEPENDENCY_MISSING")
            log_info "Use 'dot validate' to check all dependencies"
            ;;
        "$ERROR_DEPENDENCY_CYCLE")
            log_info "Use 'dot validate' to identify circular dependencies"
            ;;
        "$ERROR_VALIDATION_FAILED")
            log_info "Run 'dot validate --component $component' for detailed validation"
            ;;
        "$ERROR_INSTALLATION_FAILED")
            log_info "Check system requirements and try again with --dry-run first"
            ;;
        "$ERROR_NETWORK_ERROR")
            log_info "Check internet connection and try again"
            ;;
        "$ERROR_PERMISSION_DENIED")
            log_info "Ensure you have necessary permissions or run with appropriate privileges"
            ;;
        "$ERROR_DISK_FULL")
            log_info "Free up disk space and try again"
            ;;
    esac
}

# Wrapper for common component errors
error_installation_failed() {
    local component="$1"
    local details="${2:-}"
    error_report "$ERROR_INSTALLATION_FAILED" \
        "Installation failed for component '$component'" \
        "$component" \
        "Check component install script and system requirements" \
        "$details"
}

# =============================================================================
# RECOVERY PATTERNS
# =============================================================================

# Retry mechanism with exponential backoff
retry_with_backoff() {
    local max_attempts="$1"
    local command="$2"
    local component="${3:-}"

    local attempt=1
    local delay=1

    while [[ $attempt -le $max_attempts ]]; do
        log_debug "Attempt $attempt/$max_attempts: $command"

        if eval "$command"; then
            log_debug "Command succeeded on attempt $attempt"
            return 0
        fi

        local exit_code=$?

        if [[ $attempt -eq $max_attempts ]]; then
            error_report "$ERROR_INSTALLATION_FAILED" \
                "Command failed after $max_attempts attempts" \
                "$component" \
                "Check logs and system requirements"
            return $exit_code
        fi

        log_warn "Attempt $attempt failed, retrying in ${delay}s..."
        sleep "$delay"

        # Exponential backoff
        ((delay *= 2))
        ((attempt++))
    done
}

# Safe command execution with error handling
safe_execute() {
    local command="$1"
    local component="${2:-}"
    local critical="${3:-false}"

    log_debug "Executing: $command"

    if ! eval "$command"; then
        local exit_code=$?

        if [[ "$critical" == "true" ]]; then
            error_installation_failed "$component" "Critical command failed: $command"
            return $exit_code
        else
            log_warn "Non-critical command failed: $command"
            return 0  # Continue execution for non-critical failures
        fi
    fi

    return 0
}

# Package manager error recovery
recover_package_manager_error() {
    local package_manager="$1"
    local component="$2"
    local original_error="$3"

    log_info "Attempting package manager error recovery..."

    case "$package_manager" in
        "brew")
            log_info "Updating Homebrew and retrying..."
            if safe_execute "brew update" "$component"; then
                return 0
            fi
            ;;
        "apt-get")
            log_info "Updating package lists and retrying..."
            if safe_execute "sudo apt-get update" "$component"; then
                return 0
            fi
            ;;
        "dnf")
            log_info "Refreshing metadata and retrying..."
            if safe_execute "sudo dnf makecache --refresh" "$component"; then
                return 0
            fi
            ;;
    esac

    error_installation_failed "$component" "Package manager recovery failed: $original_error"
    return 1
}



# =============================================================================
# SIGNAL HANDLERS AND CLEANUP
# =============================================================================

# Global cleanup function
cleanup_on_error() {
    local exit_code=$?

    if [[ $exit_code -ne 0 ]]; then
        log_error "Unexpected error occurred (exit code: $exit_code)"
        log_info "Performing cleanup..."

        # Cleanup temporary files
        if [[ -n "${TMPDIR:-}" ]]; then
            find "${TMPDIR}" -name "dotfiles-*" -type f -mtime +1 -delete 2>/dev/null || true
        fi

        # Log final error summary
        log_error "Operation failed. Check logs above for details."
    fi

    exit $exit_code
}

# Set up signal handlers
setup_error_handlers() {
    trap cleanup_on_error EXIT
    trap 'exit $ERROR_USER_CANCELLED' INT TERM
}
