#!/usr/bin/env bash
set -euo pipefail

# Component: system-essentials

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log os

component_install() {
	log_info "Setting up and updating system essentials"

	# Essential tools that should be available everywhere
	local essential_tools=("curl" "git")
	local missing_tools=()
	local needs_update=false

	# Check what's missing
	for tool in "${essential_tools[@]}"; do
		if ! command -v "$tool" >/dev/null 2>&1; then
			missing_tools+=("$tool")
		fi
	done

	# If nothing is missing, we still want to update package managers
	if [[ ${#missing_tools[@]} -eq 0 ]]; then
		log_info "All essential tools are available, checking for updates"
		needs_update=true
	else
		log_info "Missing tools: ${missing_tools[*]}"
		needs_update=true
	fi

	if [[ "$needs_update" == "true" ]]; then
		# Update package managers and install missing tools
		if command -v brew >/dev/null 2>&1; then
			# macOS with Homebrew - update and install
			log_info "Updating Homebrew and installing missing tools"
			brew update || log_warn "Failed to update Homebrew"

			for tool in "${missing_tools[@]}"; do
				log_info "Installing $tool via Homebrew"
				brew install "$tool" || log_warn "Failed to install $tool via Homebrew"
			done

		elif command -v apt-get >/dev/null 2>&1; then
			# Ubuntu/Debian with apt - update and install
			log_info "Updating APT and installing missing tools"
			sudo apt-get update -y || log_warn "Failed to update APT repositories"

			for tool in "${missing_tools[@]}"; do
				sudo apt-get install -y "$tool" || log_warn "Failed to install $tool via APT"
			done

		elif command -v dnf >/dev/null 2>&1; then
			# Fedora/RHEL with dnf - update and install
			log_info "Updating DNF and installing missing tools"
			sudo dnf check-update -y || true # Returns 100 if updates available

			for tool in "${missing_tools[@]}"; do
				log_info "Installing $tool via DNF"
				sudo dnf install -y "$tool" || log_warn "Failed to install $tool via DNF"
			done

		elif command -v pacman >/dev/null 2>&1; then
			# Arch Linux with pacman - update and install
			log_info "Updating Pacman and installing missing tools"
			sudo pacman -Sy || log_warn "Failed to update Pacman repositories"

			for tool in "${missing_tools[@]}"; do
				log_info "Installing $tool via Pacman"
				sudo pacman -S --noconfirm "$tool" || log_warn "Failed to install $tool via Pacman"
			done

		else
			log_error "No supported package manager found"
			log_error "Please install the following tools manually: ${missing_tools[*]}"
			return 1
		fi
	fi

	# Verify critical tools are now available
	local still_missing=()
	for tool in "${essential_tools[@]}"; do
		if ! command -v "$tool" >/dev/null 2>&1; then
			still_missing+=("$tool")
		fi
	done

	if [[ ${#still_missing[@]} -gt 0 ]]; then
		log_error "Critical tools still missing after installation: ${still_missing[*]}"
		return 1
	fi

	log_info "All essential system tools are available and up to date"
}

component_install "$@"
