#!/usr/bin/env bash
# usage: dot init
# summary: Interactive installation wizard for first-time setup
# group: core

set -euo pipefail

# All modules are loaded by bin/dot, so we just need the environment variables
# which are exported by the main script

# Main entry point
function main() {
  # Show welcome screen
  presets_show_welcome

  # Select components
  local selection
  selection=$(presets_select)

  # Handle exit
  if [[ "$selection" == "EXIT" ]]; then
    log_info "Exiting..."
    exit 0
  fi

  # Handle custom selection
  if [[ "$selection" == "CUSTOM" ]]; then
    selection=$(presets_select_custom)

    # Validate that user selected something
    if ! presets_validate_selection "$selection"; then
      log_error "No components selected. Exiting."
      exit 0
    fi
  elif [[ "$selection" == "ALL" ]]; then
    selection=""  # Empty means install all
  fi

  # Confirm installation
  if [[ -z "$selection" ]]; then
    log_info "Installing all components..."
    local total_count
    total_count=$(categories_count_total)
    if ! ui_confirm "This will install all ${total_count} components. Continue?" "y"; then
      log_warn "Installation cancelled by user"
      exit 0
    fi
  else
    if ! presets_confirm_installation "$selection"; then
      exit 0
    fi
  fi

  # Install
  echo ""
  log_info "Starting installation..."
  echo ""

  if [[ -z "$selection" ]]; then
    "${PROJECT_ROOT}/src/bin/dot" install "$@"
  else
    "${PROJECT_ROOT}/src/bin/dot" install --only "$selection" "$@"
  fi

  # Show success screen
  presets_show_completion
}

main "$@"
