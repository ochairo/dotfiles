#!/usr/bin/env bash
set -euo pipefail
# Component: gpg_ssh - apply hardened fragments
# shellcheck disable=SC1091
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/bootstrap.sh"
core_require log fs

CONFIGS_DIR="${CONFIGS_DIR:-$DOTFILES_ROOT/configs}"

mkdir -p "$HOME/.gnupg" && chmod 700 "$HOME/.gnupg"
gpg_conf_src="$CONFIGS_DIR/.config/gnupg/gpg.conf"
if [[ -f "$gpg_conf_src" ]]; then
	fs_symlink "$gpg_conf_src" "$HOME/.gnupg/gpg.conf" gpg_ssh
else
	log_warn "No gpg.conf source found at $gpg_conf_src"
fi

mkdir -p "$HOME/.ssh/config.d"
ssh_frag_dir="$CONFIGS_DIR/.ssh/config.d"
if [[ -d "$ssh_frag_dir" ]]; then
	for f in "$ssh_frag_dir"/*; do
		[[ -f $f ]] || continue
		fs_symlink "$f" "$HOME/.ssh/config.d/$(basename "$f")" gpg_ssh
	done
else
	log_warn "No SSH fragment dir at $ssh_frag_dir"
fi

log_info "Applied GPG & SSH fragments"
