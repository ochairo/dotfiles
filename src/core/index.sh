#!/usr/bin/env bash
# index.sh - Load all dotfiles domain-specific modules
# This file loads the dotfiles management utilities

# Prevent double loading
[[ -n "${DOTFILES_INDEX_LOADED:-}" ]] && return 0
readonly DOTFILES_INDEX_LOADED=1

# Determine script directory
DOTFILES_CORE_DIR="${BASH_SOURCE[0]%/*}"

# Load register module (component registry)
if [[ -f "$DOTFILES_CORE_DIR/register.sh" ]]; then
    # shellcheck source=./register.sh
    source "$DOTFILES_CORE_DIR/register.sh"
fi

# Load ledger module (installation tracking)
if [[ -f "$DOTFILES_CORE_DIR/ledger.sh" ]]; then
    # shellcheck source=./ledger.sh
    source "$DOTFILES_CORE_DIR/ledger.sh"
fi

# Load linker module (symlink management)
if [[ -f "$DOTFILES_CORE_DIR/linker.sh" ]]; then
    # shellcheck source=./linker.sh
    source "$DOTFILES_CORE_DIR/linker.sh"
fi

# Load resolver module (dependency resolution)
if [[ -f "$DOTFILES_CORE_DIR/resolver.sh" ]]; then
    # shellcheck source=./resolver.sh
    source "$DOTFILES_CORE_DIR/resolver.sh"
fi

# Export DOTFILES_CORE_DIR for other scripts
export DOTFILES_CORE_DIR
