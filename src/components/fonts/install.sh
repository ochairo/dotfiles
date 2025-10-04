#!/usr/bin/env bash
set -euo pipefail
# Component: fonts (JetBrainsMono Nerd Font minimal)
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log os fs

install_macos() {
	if command -v brew >/dev/null 2>&1; then
		local cask="font-jetbrains-mono-nerd-font"
		if brew list --cask 2>/dev/null | grep -qx "$cask"; then
			log_info "Font already installed (Homebrew cask)"
			return 0
		fi
		brew tap homebrew/cask-fonts >/dev/null 2>&1 || true
		if brew install --cask "$cask"; then
			log_info "Installed JetBrainsMono Nerd Font via Homebrew"
		else
			log_warn "Homebrew cask install failed for $cask"
		fi
	else
		log_warn "Homebrew not found; skipping macOS font install"
	fi
}

install_linux() {
	local url="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip"
	local tmpdir
	tmpdir=$(mktemp -d)
	if curl -fsSL -o "$tmpdir/font.zip" "$url"; then
		unzip -q "$tmpdir/font.zip" -d "$tmpdir"
		mkdir -p "$HOME/.local/share/fonts"
		find "$tmpdir" -maxdepth 1 -type f -name '*.ttf' -exec cp {} "$HOME/.local/share/fonts/" \;
		fc-cache -f >/dev/null 2>&1 || true
		log_info "Installed JetBrainsMono Nerd Font"
	else
		log_warn "Font download failed"
	fi
}

if [[ $(uname -s) == Darwin* ]]; then install_macos; else install_linux; fi
