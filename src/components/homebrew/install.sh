#!/usr/bin/env bash
set -euo pipefail

# Component: homebrew

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log os

component_install() {
	# Check if running on macOS
	if [[ "$(uname -s)" != "Darwin" ]]; then
		log_info "Homebrew not needed on non-macOS systems"
		return 0
	fi

	if command -v brew >/dev/null 2>&1; then
		log_info "Homebrew already installed, checking for updates"

		# Update Homebrew itself
		log_info "Updating Homebrew"
		brew update || log_warn "Failed to update Homebrew"

		# Upgrade outdated packages (optional, but keeps system current)
		log_info "Upgrading outdated Homebrew packages"
		brew upgrade || log_warn "Failed to upgrade Homebrew packages"

		# Cleanup old versions
		log_info "Cleaning up Homebrew"
		brew cleanup || log_warn "Failed to cleanup Homebrew"

		log_info "Homebrew is up to date"
		return 0
	fi

	log_info "Installing Homebrew"

	# Check for required dependencies
	if ! command -v curl >/dev/null 2>&1; then
		log_error "curl is required for Homebrew installation"
		return 1
	fi

	# Install Homebrew via official script
	log_info "Running Homebrew installation script"
	# Security note: This downloads and executes the official Homebrew installer from GitHub
	# Verify the script source at https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh before running
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" || return 1

	# Add Homebrew to PATH for current session
	if [[ -f /opt/homebrew/bin/brew ]]; then
		eval "$(/opt/homebrew/bin/brew shellenv)"
	elif [[ -f /usr/local/bin/brew ]]; then
		eval "$(/usr/local/bin/brew shellenv)"
	fi

	# Verify installation
	if command -v brew >/dev/null 2>&1; then
		log_info "Homebrew installed successfully"
		brew --version
	else
		log_error "Homebrew installation failed"
		return 1
	fi
}

component_install "$@"
