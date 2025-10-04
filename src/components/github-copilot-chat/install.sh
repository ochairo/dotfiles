#!/usr/bin/env bash
set -euo pipefail
# Component: github-copilot-chat (cross-platform)
# Installs GitHub Copilot Chat for Neovim
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log fs

have() { command -v "$1" >/dev/null 2>&1; }

install_copilot_extension() {
	log_info "Installing GitHub CLI Copilot extension"

	if ! gh extension list | grep -q copilot; then
		if gh extension install github/gh-copilot; then
			log_info "GitHub Copilot CLI extension installed successfully"
		else
			log_warn "Failed to install GitHub Copilot CLI extension"
			return 1
		fi
	else
		log_info "GitHub Copilot CLI extension already installed"
	fi
}

setup_neovim_plugin() {
	local dotfiles_nvim_config="$DOTFILES_ROOT/configs/.config/nvim/lua/user/plugins/copilot_chat.lua"
	local nvim_plugin_link="$HOME/.config/nvim/lua/user/plugins/copilot_chat.lua"

	log_info "Setting up Neovim Copilot configuration in dotfiles"

	# Check if the configuration file exists in dotfiles
	if [[ -f "$dotfiles_nvim_config" ]]; then
		log_info "Copilot configuration found in dotfiles: $dotfiles_nvim_config"
	else
		log_warn "Copilot configuration not found in dotfiles. Expected: $dotfiles_nvim_config"
		return 1
	fi

	# The nvim component should handle symlinking, but let's verify the symlink exists
	local nvim_config_dir="$HOME/.config/nvim"
	if [[ ! -L "$nvim_config_dir" && ! -d "$nvim_config_dir" ]]; then
		log_warn "Neovim config directory not found or not symlinked. Run: ../../bin/dot install --only nvim"
		return 1
	fi

	# Ensure the specific plugin file is symlinked
	if [[ ! -L "$nvim_plugin_link" ]]; then
		log_info "Creating symlink for copilot_chat.lua plugin"
		ln -sf "$dotfiles_nvim_config" "$nvim_plugin_link" || {
			log_warn "Failed to create symlink for copilot_chat.lua"
			return 1
		}
	else
		log_info "Copilot plugin symlink already exists"
	fi

	log_info "Neovim Copilot configuration is managed by dotfiles system"
}

check_github_auth() {
	log_info "Checking GitHub authentication"

	if ! gh auth status >/dev/null 2>&1; then
		log_warn "GitHub CLI not authenticated. Please run: gh auth login"
		log_info "After authentication, you may need to enable Copilot in your GitHub account"
		return 1
	else
		log_info "GitHub CLI is authenticated"
	fi
}

main() {
	# Check prerequisites
	if ! have gh; then
		log_error "GitHub CLI (gh) is required but not found. Please install the 'gh' component first."
		return 1
	fi

	if ! have nvim; then
		log_error "Neovim is required but not found. Please install the 'nvim' component first."
		return 1
	fi

	# Check GitHub authentication
	check_github_auth || log_warn "GitHub authentication may be required for Copilot to work"

	# Install GitHub CLI Copilot extension
	install_copilot_extension

	# Setup Neovim plugin configuration
	setup_neovim_plugin

	log_info "GitHub Copilot Chat setup complete!"
	log_info "Copilot plugins added to Neovim configuration"
	log_info "Next steps:"
	log_info "1. Restart Neovim or run :Lazy sync to install plugins"
	log_info "2. Run :Copilot auth in Neovim to authenticate"
	log_info "3. Use <leader>cc to start Copilot Chat"
	log_info "4. Use Ctrl+J in insert mode to accept Copilot suggestions"
}

main "$@"
