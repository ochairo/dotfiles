#!/usr/bin/env bash
set -euo pipefail
# Component: zsh (cross-platform)
# Installs or ensures a usable modern zsh on macOS & Linux.
# Optional behavior:
#   DOTFILES_ZSH_SET_LOGIN=1  -> attempt to set default login shell (may prompt for password)
#   DOTFILES_ZSH_ALLOW_OLD=1  -> do not warn if version < 5.8

# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log fs

want_login=${DOTFILES_ZSH_SET_LOGIN:-1} # Default to 1 (auto-set login shell)
allow_old=${DOTFILES_ZSH_ALLOW_OLD:-0}

have() { command -v "$1" >/dev/null 2>&1; }

install_mac() {
	if have brew; then
		if ! brew list zsh >/dev/null 2>&1; then
			log_info "Installing zsh via Homebrew"
			brew install zsh || log_warn "brew install zsh failed"
		else
			log_info "Homebrew zsh already installed"
		fi
	else
		log_warn "Homebrew not found; relying on system /bin/zsh"
	fi
}

install_linux() {
	# Try package managers in preference order
	if have apt-get; then
		if ! dpkg -s zsh >/dev/null 2>&1; then
			log_info "Installing zsh via apt-get"
			sudo apt-get update -y || true
			sudo apt-get install -y zsh || log_warn "apt-get install zsh failed"
		else
			log_info "zsh already installed (dpkg)"
		fi
	elif have dnf; then
		if ! rpm -q zsh >/dev/null 2>&1; then
			log_info "Installing zsh via dnf"
			sudo dnf install -y zsh || log_warn "dnf install zsh failed"
		else
			log_info "zsh already installed (rpm)"
		fi
	elif have pacman; then
		if ! pacman -Qi zsh >/dev/null 2>&1; then
			log_info "Installing zsh via pacman"
			sudo pacman -Sy --noconfirm zsh || log_warn "pacman install zsh failed"
		else
			log_info "zsh already installed (pacman)"
		fi
	else
		if have zsh; then
			log_info "zsh present via unknown manager (skipping install)"
		else
			log_warn "No supported package manager found; cannot install zsh automatically"
		fi
	fi
}

set_login_shell() {
	local target="$1"
	[[ $want_login == 1 ]] || return 0
	if [[ ! -x $target ]]; then
		log_warn "Login shell target not executable: $target"
		return 0
	fi

	# Check if we're already using the exact same zsh
	if [[ ${SHELL:-} == "$target" ]]; then
		log_info "Login shell already $target"
		return 0
	fi

	# Check if we're already using any zsh (don't switch between different zsh versions unnecessarily)
	if [[ ${SHELL:-} == *"/zsh" ]]; then
		log_info "Already using zsh (${SHELL}), skipping change to $target"
		log_info "If you want to switch to Homebrew zsh, run: chsh -s $target"
		return 0
	fi

	# Ensure /etc/shells contains it
	if ! grep -Fxq "$target" /etc/shells 2>/dev/null; then
		if have sudo; then
			log_info "Adding $target to /etc/shells"
			echo "$target" | sudo tee -a /etc/shells >/dev/null || log_warn "Could not append $target to /etc/shells"
		else
			log_warn "sudo not available; cannot register $target in /etc/shells"
			log_info "You may need to manually add '$target' to /etc/shells"
		fi
	fi

	# Try to change the login shell
	if have chsh; then
		log_info "Changing login shell to $target"
		if chsh -s "$target"; then
			log_info "Login shell changed successfully. You may need to restart your terminal or re-login."
		else
			log_warn "chsh failed - you may need to run: chsh -s $target"
			log_info "Or use: sudo usermod -s $target \$USER"
		fi
	else
		log_warn "chsh not available; cannot change login shell automatically"
		log_info "Please manually change your shell to: $target"
	fi
}

main() {
	local uname_s
	uname_s=$(uname -s 2>/dev/null || echo Unknown)
	case $uname_s in
	Darwin) install_mac ;;
	Linux) install_linux ;;
	*) log_warn "Unsupported OS $uname_s; assuming zsh present" ;;
	esac

	if ! have zsh; then
		log_error "zsh not found after attempted install"
		return 1
	fi

	local zbin
	# Prefer Homebrew zsh if available on macOS
	if [[ $uname_s == Darwin ]] && have brew && [[ -x "$(brew --prefix)/bin/zsh" ]]; then
		zbin="$(brew --prefix)/bin/zsh"
	else
		zbin="$(command -v zsh)"
	fi

	# Version check
	local ver
	ver=$("$zbin" --version 2>/dev/null || true)
	log_info "Detected zsh: $zbin ($ver)"
	if [[ $allow_old == 0 ]]; then
		# Rough heuristic: encourage >=5.8
		if printf '%s' "$ver" | grep -Eo '[0-9]+\.[0-9]+' | awk 'BEGIN{req=5.8} {if($1+0 < req){exit 0}else{exit 1}}'; then
			log_warn "zsh version may be older than 5.8 (set DOTFILES_ZSH_ALLOW_OLD=1 to silence)"
		fi
	fi

	set_login_shell "$zbin"

	# Symlink shell configuration files directly
	local shell_dir="$CONFIGS_DIR/.config/shell"

	# Core zsh files
	if [[ -f "$shell_dir/.zshrc" ]]; then
		fs_symlink "$shell_dir/.zshrc" "$HOME/.zshrc" zsh
		log_info "Linked .zshrc"
	else
		log_warn "No .zshrc found at $shell_dir/.zshrc"
	fi

	if [[ -f "$shell_dir/.zshenv" ]]; then
		fs_symlink "$shell_dir/.zshenv" "$HOME/.zshenv" zsh
		log_info "Linked .zshenv"
	else
		log_warn "No .zshenv found at $shell_dir/.zshenv"
	fi

	# Zsh modular files
	if [[ -f "$shell_dir/.zsh_aliases" ]]; then
		fs_symlink "$shell_dir/.zsh_aliases" "$HOME/.zsh_aliases" zsh
		log_info "Linked .zsh_aliases"
	else
		log_warn "No .zsh_aliases found at $shell_dir/.zsh_aliases"
	fi

	if [[ -f "$shell_dir/.zsh_functions" ]]; then
		fs_symlink "$shell_dir/.zsh_functions" "$HOME/.zsh_functions" zsh
		log_info "Linked .zsh_functions"
	else
		log_warn "No .zsh_functions found at $shell_dir/.zsh_functions"
	fi

	# Performance optimization files
	if [[ -f "$shell_dir/.zsh_lazy" ]]; then
		fs_symlink "$shell_dir/.zsh_lazy" "$HOME/.zsh_lazy" zsh
		log_info "Linked .zsh_lazy"
	else
		log_warn "No .zsh_lazy found at $shell_dir/.zsh_lazy"
	fi

	if [[ -f "$shell_dir/.zshrc-fast" ]]; then
		fs_symlink "$shell_dir/.zshrc-fast" "$HOME/.zshrc-fast" zsh
		log_info "Linked .zshrc-fast"
	else
		log_warn "No .zshrc-fast found at $shell_dir/.zshrc-fast"
	fi

	if [[ -f "$shell_dir/.zsh_performance" ]]; then
		fs_symlink "$shell_dir/.zsh_performance" "$HOME/.zsh_performance" zsh
		log_info "Linked .zsh_performance"
	else
		log_warn "No .zsh_performance found at $shell_dir/.zsh_performance"
	fi

	if [[ -f "$shell_dir/.zsh_safety" ]]; then
		fs_symlink "$shell_dir/.zsh_safety" "$HOME/.zsh_safety" zsh
		log_info "Linked .zsh_safety"
	else
		log_warn "No .zsh_safety found at $shell_dir/.zsh_safety"
	fi
}

main "$@"
