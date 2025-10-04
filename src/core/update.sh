#!/usr/bin/env bash
# core/update.sh - repository update & revision utilities
set -euo pipefail

source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/log.sh"
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/constants.sh"

update_repo_branch() {
	if git -C "$DOTFILES_ROOT" rev-parse --abbrev-ref HEAD >/dev/null 2>&1; then
		git -C "$DOTFILES_ROOT" rev-parse --abbrev-ref HEAD
	else
		echo main
	fi
}

update_current_ref() { git -C "$DOTFILES_ROOT" rev-parse --short HEAD 2>/dev/null || true; }
update_remote_ref() {
	local branch
	branch=$(update_repo_branch)
	git -C "$DOTFILES_ROOT" fetch --quiet origin "$branch" || true
	git -C "$DOTFILES_ROOT" rev-parse --short "origin/$branch" 2>/dev/null || true
}

update_state() {
	local cur remote
	cur=$(update_current_ref)
	remote=$(update_remote_ref)
	if [[ -z $cur || -z $remote ]]; then
		echo unknown
		return 0
	fi
	if [[ $cur == $remote ]]; then echo up-to-date; else echo out-of-date; fi
}

update_pull() {
	local branch
	branch=$(update_repo_branch)
	git -C "$DOTFILES_ROOT" pull --ff-only origin "$branch"
}
