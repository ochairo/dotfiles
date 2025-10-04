#!/usr/bin/env bash
set -euo pipefail
# Component: azure-cli (az)
# Installs Microsoft Azure CLI across macOS and Linux distros.
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log

have() { command -v "$1" >/dev/null 2>&1; }

install_mac() {
	if have brew; then
		if ! brew list azure-cli >/dev/null 2>&1; then
			log_info "Installing azure-cli via Homebrew"
			brew install azure-cli || log_warn "brew install azure-cli failed"
		else
			log_info "azure-cli already installed (brew)"
		fi
	else
		log_warn "Homebrew not found; cannot install azure-cli automatically"
	fi
}

install_linux() {
	if have apt-get; then
		if ! dpkg -s azure-cli >/dev/null 2>&1; then
			log_info "Installing azure-cli via Microsoft apt repo"
			# Security note: This downloads and executes the official Azure CLI installer from Microsoft
			# Verify the script source at https://aka.ms/InstallAzureCLIDeb before running
			curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash || log_warn "Azure CLI install script failed"
		else
			log_info "azure-cli already installed (dpkg)"
		fi
	elif have dnf; then
		if ! rpm -q azure-cli >/dev/null 2>&1; then
			log_info "Installing azure-cli via Microsoft dnf repo"
			sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc || true
			sudo sh -c 'echo -e "[azure-cli]\nname=Azure CLI\nbaseurl=https://packages.microsoft.com/yumrepos/azure-cli\nenabled=1\ngpgcheck=1\ngpgkey=https://packages.microsoft.com/keys/microsoft.asc" > /etc/yum.repos.d/azure-cli.repo'
			sudo dnf install -y azure-cli || log_warn "dnf install azure-cli failed"
		else
			log_info "azure-cli already installed (rpm)"
		fi
	elif have pacman; then
		if ! pacman -Qi azure-cli >/dev/null 2>&1; then
			log_info "Installing azure-cli via pacman (AUR may be required)"
			log_warn "pacman direct install not implemented; install manually or via AUR helper"
		else
			log_info "azure-cli already installed (pacman)"
		fi
	else
		if have az; then
			log_info "azure-cli present via unknown manager"
		else
			log_warn "No supported package manager found; manual install required for azure-cli"
		fi
	fi
}

post_install() {
	if have az; then
		local v
		v=$(az version 2>/dev/null | head -1 || true)
		log_info "azure-cli version detected"
	fi
}

main() {
	local os
	os=$(uname -s 2>/dev/null || echo Unknown)
	case $os in
	Darwin) install_mac ;;
	Linux) install_linux ;;
	*) log_warn "Unsupported OS $os; assuming azure-cli present" ;;
	esac
	post_install
}

main "$@"
