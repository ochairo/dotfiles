#!/usr/bin/env bash
# index.sh - Load all dotfiles domain-specific modules
# This file loads services and orchestrators

# Prevent double loading
[[ -n "${DOTFILES_INDEX_LOADED:-}" ]] && return 0
readonly DOTFILES_INDEX_LOADED=1

# Determine script directory
DOTFILES_CORE_DIR="${BASH_SOURCE[0]%/*}"

# Load services (business logic)
for service in "$DOTFILES_CORE_DIR/services"/*.sh; do
    # shellcheck source=/dev/null
    [[ -f "$service" ]] && source "$service"
done

# Load orchestrators (domain workflows)
for orchestrator in "$DOTFILES_CORE_DIR/orchestrators"/*.sh; do
    # shellcheck source=/dev/null
    [[ -f "$orchestrator" ]] && source "$orchestrator"
done

# Export DOTFILES_CORE_DIR for other scripts
export DOTFILES_CORE_DIR
