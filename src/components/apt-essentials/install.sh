#!/usr/bin/env bash
set -euo pipefail

# Component: apt-essentials

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log os

component_install() {
	# Check if running on a system with apt
	if ! command -v apt-get >/dev/null 2>&1; then
		log_info "APT not available on this system, skipping apt-essentials"
		return 0
	fi

	log_info "Setting up and updating APT essentials for Ubuntu/Debian"

	# Always update package lists first
	log_info "Updating package lists"
	if ! sudo apt-get update -y; then
		log_warn "Failed to update package lists, repositories may be unavailable"
		# Don't fail completely, as some packages might still be installable
	fi

	# Upgrade existing packages
	log_info "Upgrading existing packages"
	if ! sudo apt-get upgrade -y; then
		log_warn "Failed to upgrade some packages, continuing anyway"
	fi

	# Install essential packages
	local packages=("curl" "wget" "unzip" "build-essential" "ca-certificates" "gnupg" "lsb-release" "software-properties-common")
	local failed_packages=()

	for package in "${packages[@]}"; do
		if ! dpkg -l | grep -q "^ii  $package "; then
			log_info "Installing $package"
			if sudo apt-get install -y "$package" 2>/dev/null; then
				log_info "Successfully installed $package"
			else
				log_warn "Failed to install $package"
				failed_packages+=("$package")
			fi
		else
			log_info "$package already installed"
		fi
	done

	# Clean up APT cache
	log_info "Cleaning up APT cache"
	sudo apt-get autoremove -y || log_warn "Failed to autoremove packages"
	sudo apt-get autoclean || log_warn "Failed to clean APT cache"

	# Report on failed packages
	if [[ ${#failed_packages[@]} -gt 0 ]]; then
		log_warn "Some packages failed to install: ${failed_packages[*]}"
		log_warn "This may be due to repository issues or package availability"
	fi

	# Verify critical tools are available
	local critical_tools=("curl" "wget")
	for tool in "${critical_tools[@]}"; do
		if ! command -v "$tool" >/dev/null 2>&1; then
			log_error "Critical tool $tool is not available after installation"
			return 1
		fi
	done

	log_info "APT essentials setup and update completed"
}

component_install "$@"
