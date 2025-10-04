#!/usr/bin/env bash
set -euo pipefail

# Component: tree-sitter

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log os

component_install() {
	if command -v tree-sitter >/dev/null 2>&1; then
		log_info "tree-sitter CLI already installed"
		tree-sitter --version
		return 0
	fi

	log_info "Installing tree-sitter CLI"

	if command -v brew >/dev/null 2>&1; then
		# macOS with Homebrew
		brew install tree-sitter-cli || return 1
	elif command -v apt-get >/dev/null 2>&1; then
		# Ubuntu/Debian with apt - try package first, fallback to binary download
		if sudo apt-get update -y && sudo apt-get install -y tree-sitter-cli 2>/dev/null; then
			log_info "Installed tree-sitter CLI via apt"
		else
			log_info "tree-sitter-cli not available via apt, downloading binary..."
			install_tree_sitter_binary || return 1
		fi
	elif command -v dnf >/dev/null 2>&1; then
		# Fedora/RHEL with dnf
		sudo dnf install -y tree-sitter-cli || install_tree_sitter_binary || return 1
	elif command -v pacman >/dev/null 2>&1; then
		# Arch Linux with pacman
		sudo pacman -S --noconfirm tree-sitter-cli || install_tree_sitter_binary || return 1
	else
		log_info "No supported package manager found, downloading binary..."
		install_tree_sitter_binary || return 1
	fi

	# Verify installation
	if command -v tree-sitter >/dev/null 2>&1; then
		log_info "tree-sitter CLI installed successfully"
		tree-sitter --version
	else
		log_error "tree-sitter CLI installation failed"
		return 1
	fi
}

install_tree_sitter_binary() {
	local arch
	local os_type
	local download_url
	local install_dir="/usr/local/bin"

	# Detect architecture (GitHub release naming)
	case "$(uname -m)" in
	x86_64) arch="x64" ;;
	aarch64 | arm64) arch="arm64" ;;
	*)
		log_error "Unsupported architecture: $(uname -m)"
		return 1
		;;
	esac

	# Detect OS (GitHub release naming)
	case "$(uname -s)" in
	Linux) os_type="linux" ;;
	Darwin) os_type="macos" ;;
	*)
		log_error "Unsupported OS: $(uname -s)"
		return 1
		;;
	esac

	# Construct download URL for specific version
	download_url="https://github.com/tree-sitter/tree-sitter/releases/download/v0.25.10/tree-sitter-${os_type}-${arch}.gz"

	log_info "Downloading tree-sitter binary from ${download_url}"

	# Create temporary directory
	local temp_dir
	temp_dir=$(mktemp -d)

	# Download and install
	if curl -L -o "${temp_dir}/tree-sitter.gz" "${download_url}"; then
		if gunzip "${temp_dir}/tree-sitter.gz" 2>/dev/null; then
			chmod +x "${temp_dir}/tree-sitter"

			# Install to /usr/local/bin (requires sudo) or ~/.local/bin
			if sudo mv "${temp_dir}/tree-sitter" "${install_dir}/tree-sitter" 2>/dev/null; then
				log_info "Installed tree-sitter to ${install_dir}/tree-sitter"
			else
				# Fallback to user directory
				install_dir="$HOME/.local/bin"
				mkdir -p "${install_dir}"
				mv "${temp_dir}/tree-sitter" "${install_dir}/tree-sitter"
				log_info "Installed tree-sitter to ${install_dir}/tree-sitter"

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
			log_error "Failed to extract tree-sitter binary"
			rm -rf "${temp_dir}"
			return 1
		fi
	else
		log_error "Failed to download tree-sitter binary"
		rm -rf "${temp_dir}"
		return 1
	fi
}

component_install "$@"
