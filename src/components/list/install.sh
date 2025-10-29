#!/usr/bin/env bash
set -euo pipefail

# Component: list

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/src/lib/index.sh" 2>/dev/null || true
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/src/core/index.sh" 2>/dev/null || true


# Set up error handlers
setup_error_handlers

component_install() {
    local component_name="list"

    msg_info "Installing $component_name"

    # Check if already installed
    if command -v list >/dev/null 2>&1; then
        msg_info "$component_name already installed"
        return 0
    fi

    # Install via package manager with proper error handling
    if command -v brew >/dev/null 2>&1; then
        if ! retry_with_backoff 3 "brew install list" "$component_name"; then
            recover_package_manager_error "brew" "$component_name" "brew install failed" 2>/dev/null || msg_error "brew install failed for $component_name"
            return $ERROR_INSTALLATION_FAILED
        fi
    elif command -v apt-get >/dev/null 2>&1; then
        if ! safe_execute "sudo apt-get update -y" "$component_name" true; then
            return $ERROR_INSTALLATION_FAILED
        fi
        if ! retry_with_backoff 3 "sudo apt-get install -y list" "$component_name"; then
            recover_package_manager_error "apt-get" "$component_name" "apt-get install failed" 2>/dev/null || msg_error "apt-get install failed for $component_name"
            return $ERROR_INSTALLATION_FAILED
        fi
    elif command -v dnf >/dev/null 2>&1; then
        if ! retry_with_backoff 3 "sudo dnf install -y list" "$component_name"; then
            recover_package_manager_error "dnf" "$component_name" "dnf install failed" 2>/dev/null || msg_error "dnf install failed for $component_name"
            return $ERROR_INSTALLATION_FAILED
        fi
    else
        error_installation_failed "$component_name" "No supported package manager found (brew, apt-get, or dnf)" 2>/dev/null || msg_error "No supported package manager found (brew, apt-get, or dnf)"
        return $ERROR_INSTALLATION_FAILED
    fi

    # Verify installation
    if ! command -v list >/dev/null 2>&1; then
        error_installation_failed "$component_name" "Installation appeared to succeed but command not found" 2>/dev/null || msg_error "Installation appeared to succeed but command not found"
        return $ERROR_INSTALLATION_FAILED
    fi

    msg_success "Successfully installed $component_name"
    return 0
}

component_install "$@"
