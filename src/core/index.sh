#!/usr/bin/env bash
# index.sh - Load all dotfiles domain-specific modules
# This file loads services and orchestrators

# Prevent double loading
[[ -n "${DOTFILES_INDEX_LOADED:-}" ]] && return 0
readonly DOTFILES_INDEX_LOADED=1

# Determine script directory
DOTFILES_CORE_DIR="${BASH_SOURCE[0]%/*}"

if [[ -f "$DOTFILES_CORE_DIR/services/register/register.sh" ]]; then
    # shellcheck source=/dev/null
    source "$DOTFILES_CORE_DIR/services/register/register.sh"
fi

# Load segmented service loaders
[[ -f "$DOTFILES_CORE_DIR/services/ledger/ledger.sh" ]] && source "$DOTFILES_CORE_DIR/services/ledger/ledger.sh"
[[ -f "$DOTFILES_CORE_DIR/services/linker/linker.sh" ]] && source "$DOTFILES_CORE_DIR/services/linker/linker.sh"

# Load services (business logic)
for service in "$DOTFILES_CORE_DIR/services"/*.sh; do
    # shellcheck source=/dev/null
    [[ -f "$service" ]] && source "$service"
done

# Load nested service directories (resolver, etc.)
for nested in "$DOTFILES_CORE_DIR/services"/*/*.sh; do
    # shellcheck source=/dev/null
    [[ -f "$nested" ]] && source "$nested"
done

# Load orchestrators (domain workflows)
for orchestrator in "$DOTFILES_CORE_DIR/orchestrators"/*.sh; do
    # shellcheck source=/dev/null
    [[ -f "$orchestrator" ]] && source "$orchestrator"
done

# Export DOTFILES_CORE_DIR for other scripts
export DOTFILES_CORE_DIR
