#!/usr/bin/env bash
# register/init.sh - Guard & defaults
[[ -n "${DOTFILES_COMPONENTS_INIT_LOADED:-}" ]] && return 0
readonly DOTFILES_COMPONENTS_INIT_LOADED=1

# Establish COMPONENTS_DIR default robustly:
# 1. If already set, keep it.
# 2. Prefer DOTFILES_ROOT/src/components if present.
# 3. Else fallback to $HOME/.dotfiles/components.
if [[ -z "${COMPONENTS_DIR:-}" ]]; then
	if [[ -n "${DOTFILES_ROOT:-}" && -d "${DOTFILES_ROOT}/src/components" ]]; then
		COMPONENTS_DIR="${DOTFILES_ROOT}/src/components"
	else
		COMPONENTS_DIR="$HOME/.dotfiles/components"
	fi
fi
export COMPONENTS_DIR
