#!/usr/bin/env bash
set -euo pipefail
# Component: sdkman
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log os

SDKMAN_DIR="${SDKMAN_DIR:-$HOME/.sdkman}"

component_install() {
	# Check if SDKMAN is already installed
	if [[ -d "$SDKMAN_DIR" && -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
		log_info "SDKMAN already installed at $SDKMAN_DIR"
		return 0
	fi

	# Ensure required tools are available
	if ! command -v curl >/dev/null 2>&1; then
		log_error "curl is required for SDKMAN installation"
		return 1
	fi

	if ! command -v unzip >/dev/null 2>&1; then
		log_error "unzip is required for SDKMAN installation"
		return 1
	fi

	log_info "Installing SDKMAN..."

	# Download SDKMAN installer to a temporary file for verification
	local temp_installer
	temp_installer=$(mktemp)

	# Download the installer
	if ! curl -fsSL "https://get.sdkman.io" -o "$temp_installer"; then
		log_error "Failed to download SDKMAN installer"
		rm -f "$temp_installer"
		return 1
	fi

	# Basic verification - check if it looks like a shell script
	if ! grep -q "#!/bin/bash" "$temp_installer" || ! grep -q "SDKMAN" "$temp_installer"; then
		log_error "Downloaded file doesn't appear to be the SDKMAN installer"
		rm -f "$temp_installer"
		return 1
	fi

	# Make installer executable
	chmod +x "$temp_installer"

	# Run the installer
	log_info "Running SDKMAN installer..."
	if SDKMAN_DIR="$SDKMAN_DIR" "$temp_installer"; then
		log_info "SDKMAN installed successfully"
	else
		log_error "SDKMAN installation failed"
		rm -f "$temp_installer"
		return 1
	fi

	# Clean up
	rm -f "$temp_installer"

	# Verify installation
	if [[ -s "$SDKMAN_DIR/bin/sdkman-init.sh" ]]; then
		log_info "SDKMAN installation verified"

		# Source SDKMAN to make sdk command available
		# shellcheck disable=SC1090
		source "$SDKMAN_DIR/bin/sdkman-init.sh"

		# Display version information
		if command -v sdk >/dev/null 2>&1; then
			local version
			version=$(sdk version 2>/dev/null | head -1 || echo "unknown")
			log_info "SDKMAN version: $version"
		fi
	else
		log_error "SDKMAN installation verification failed"
		return 1
	fi

	log_info "SDKMAN installation complete"
	log_info "Add 'source \"\$HOME/.sdkman/bin/sdkman-init.sh\"' to your shell profile"
	log_info "Use 'sdk list' to see available SDKs"
}

component_install "$@"
