#!/usr/bin/env bash
set -euo pipefail

# Component: dnf-essentials

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log os

component_install() {
	# Check if running on a system with dnf
	if ! command -v dnf >/dev/null 2>&1; then
		log_info "DNF not available on this system, skipping dnf-essentials"
		return 0
	fi

	log_info "Setting up and updating DNF essentials for Fedora/RHEL"

	# Update package lists and system
	log_info "Updating package lists and system"
	if ! sudo dnf check-update -y; then
		# dnf check-update returns 100 if updates are available, which is normal
		if [[ $? -ne 100 ]]; then
			log_warn "Failed to check for updates"
		fi
	fi

	# Upgrade existing packages
	log_info "Upgrading existing packages"
	sudo dnf upgrade -y || log_warn "Failed to upgrade some packages, continuing anyway"

	# Install essential packages
	local packages=("curl" "wget" "unzip" "gcc" "make" "git" "ca-certificates" "gnupg")
	local failed_packages=()

	for package in "${packages[@]}"; do
		if ! rpm -q "$package" >/dev/null 2>&1; then
			log_info "Installing $package"
			if sudo dnf install -y "$package" 2>/dev/null; then
				log_info "Successfully installed $package"
			else
				log_warn "Failed to install $package"
				failed_packages+=("$package")
			fi
		else
			log_info "$package already installed"
		fi
	done

	# Clean up DNF cache
	log_info "Cleaning up DNF cache"
	sudo dnf autoremove -y || log_warn "Failed to autoremove packages"
	sudo dnf clean all || log_warn "Failed to clean DNF cache"

	# Report on failed packages
	if [[ ${#failed_packages[@]} -gt 0 ]]; then
		log_warn "Some packages failed to install: ${failed_packages[*]}"
	fi

	# Verify critical tools are available
	local critical_tools=("curl" "wget" "git")
	for tool in "${critical_tools[@]}"; do
		if ! command -v "$tool" >/dev/null 2>&1; then
			log_error "Critical tool $tool is not available after installation"
			return 1
		fi
	done

	log_info "DNF essentials setup and update completed"
}

component_install "$@"
