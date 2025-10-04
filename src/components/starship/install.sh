#!/usr/bin/env bash
set -euo pipefail
# Component: starship
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log fs

component_install() {
	if command -v starship >/dev/null 2>&1; then
		log_info "Starship already installed"
	else
		log_info "Installing starship"
		if command -v brew >/dev/null 2>&1; then
			# macOS with Homebrew
			brew install starship || return 1
		elif command -v apt-get >/dev/null 2>&1; then
			# Ubuntu/Debian with apt
			if ! sudo apt-get update -y || ! sudo apt-get install -y starship 2>/dev/null; then
				log_info "starship not available via apt, using install script..."
				install_starship_via_script || return 1
			fi
		elif command -v dnf >/dev/null 2>&1; then
			# Fedora/RHEL with dnf
			sudo dnf copr enable -y atim/starship && sudo dnf install -y starship || install_starship_via_script || return 1
		elif command -v pacman >/dev/null 2>&1; then
			# Arch Linux with pacman
			sudo pacman -S --noconfirm starship || install_starship_via_script || return 1
		else
			log_info "No supported package manager found, using install script..."
			install_starship_via_script || return 1
		fi
	fi

	# Install config
	fs_symlink_component_files starship
}

install_starship_via_script() {
	if command -v curl >/dev/null 2>&1; then
		log_info "Installing starship via official install script"
		# Security note: This downloads and executes the official Starship installer from starship.rs
		# Verify the script source at https://starship.rs/install.sh before running
		curl -sS https://starship.rs/install.sh | sh -s -- --yes || return 1
	else
		log_error "curl not available for starship installation"
		return 1
	fi
}

component_install "$@"
