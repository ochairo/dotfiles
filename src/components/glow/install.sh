#!/usr/bin/env bash
set -euo pipefail

# Component: glow

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log

component_install() {
	if command -v glow >/dev/null 2>&1; then
		log_info "glow already installed"
		return 0
	fi

	log_info "Installing glow"

	if command -v brew >/dev/null 2>&1; then
		# macOS with Homebrew
		brew install glow || return 1
	elif command -v apt-get >/dev/null 2>&1; then
		# Ubuntu/Debian - install from GitHub releases
		install_glow_binary || return 1
	elif command -v dnf >/dev/null 2>&1; then
		# Fedora/RHEL - install from GitHub releases
		install_glow_binary || return 1
	elif command -v pacman >/dev/null 2>&1; then
		# Arch Linux
		sudo pacman -S --noconfirm glow || install_glow_binary || return 1
	else
		install_glow_binary || return 1
	fi

	# Verify installation
	if command -v glow >/dev/null 2>&1; then
		log_info "glow installed successfully"
	else
		log_error "glow installation failed"
		return 1
	fi
}

install_glow_binary() {
	local arch
	local os_type
	local download_url
	local install_dir="/usr/local/bin"

	# Detect architecture
	case "$(uname -m)" in
	x86_64) arch="x86_64" ;;
	aarch64 | arm64) arch="arm64" ;;
	*)
		log_error "Unsupported architecture: $(uname -m)"
		return 1
		;;
	esac

	# Detect OS
	case "$(uname -s)" in
	Linux) os_type="Linux" ;;
	Darwin) os_type="Darwin" ;;
	*)
		log_error "Unsupported OS: $(uname -s)"
		return 1
		;;
	esac

	# Get latest release
	local latest_version
	latest_version=$(curl -s https://api.github.com/repos/charmbracelet/glow/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

	download_url="https://github.com/charmbracelet/glow/releases/download/${latest_version}/glow_${latest_version#v}_${os_type}_${arch}.tar.gz"

	log_info "Downloading glow from ${download_url}"

	# Create temporary directory
	local temp_dir
	temp_dir=$(mktemp -d)

	# Download and install
	if curl -L -o "${temp_dir}/glow.tar.gz" "${download_url}"; then
		tar -xzf "${temp_dir}/glow.tar.gz" -C "${temp_dir}"

		# Install to /usr/local/bin (requires sudo) or ~/.local/bin
		if sudo mv "${temp_dir}/glow" "${install_dir}/glow" 2>/dev/null; then
			log_info "Installed glow to ${install_dir}/glow"
		else
			# Fallback to user directory
			install_dir="$HOME/.local/bin"
			mkdir -p "${install_dir}"
			mv "${temp_dir}/glow" "${install_dir}/glow"
			log_info "Installed glow to ${install_dir}/glow"

			# Add to PATH if not already there
			if [[ ":$PATH:" != *":$install_dir:"* ]]; then
				export PATH="${install_dir}:$PATH"
				log_info "Added ${install_dir} to PATH for current session"
			fi
		fi

		# Cleanup
		rm -rf "${temp_dir}"
		return 0
	else
		log_error "Failed to download glow"
		rm -rf "${temp_dir}"
		return 1
	fi
}

component_install "$@"
