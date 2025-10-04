#!/usr/bin/env bash
set -euo pipefail

# Component: lazydocker

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log

component_install() {
	if command -v lazydocker >/dev/null 2>&1; then
		log_info "lazydocker already installed"
		return 0
	fi

	log_info "Installing lazydocker"

	if command -v brew >/dev/null 2>&1; then
		# macOS with Homebrew
		brew install lazydocker || return 1
	elif command -v apt-get >/dev/null 2>&1; then
		# Ubuntu/Debian - install from GitHub releases
		install_lazydocker_binary || return 1
	elif command -v dnf >/dev/null 2>&1; then
		# Fedora/RHEL - install from GitHub releases
		install_lazydocker_binary || return 1
	elif command -v pacman >/dev/null 2>&1; then
		# Arch Linux with AUR
		if command -v yay >/dev/null 2>&1; then
			yay -S --noconfirm lazydocker || install_lazydocker_binary || return 1
		else
			install_lazydocker_binary || return 1
		fi
	else
		install_lazydocker_binary || return 1
	fi

	# Verify installation
	if command -v lazydocker >/dev/null 2>&1; then
		log_info "lazydocker installed successfully"
	else
		log_error "lazydocker installation failed"
		return 1
	fi
}

install_lazydocker_binary() {
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
	latest_version=$(curl -s https://api.github.com/repos/jesseduffield/lazydocker/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')

	download_url="https://github.com/jesseduffield/lazydocker/releases/download/${latest_version}/lazydocker_${latest_version#v}_${os_type}_${arch}.tar.gz"

	log_info "Downloading lazydocker from ${download_url}"

	# Create temporary directory
	local temp_dir
	temp_dir=$(mktemp -d)

	# Download and install
	if curl -L -o "${temp_dir}/lazydocker.tar.gz" "${download_url}"; then
		tar -xzf "${temp_dir}/lazydocker.tar.gz" -C "${temp_dir}"

		# Install to /usr/local/bin (requires sudo) or ~/.local/bin
		if sudo mv "${temp_dir}/lazydocker" "${install_dir}/lazydocker" 2>/dev/null; then
			log_info "Installed lazydocker to ${install_dir}/lazydocker"
		else
			# Fallback to user directory
			install_dir="$HOME/.local/bin"
			mkdir -p "${install_dir}"
			mv "${temp_dir}/lazydocker" "${install_dir}/lazydocker"
			log_info "Installed lazydocker to ${install_dir}/lazydocker"

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
		log_error "Failed to download lazydocker"
		rm -rf "${temp_dir}"
		return 1
	fi
}

component_install "$@"
