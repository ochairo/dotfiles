#!/usr/bin/env bash
# core/constants.sh - Central constants & path resolution
# Single source of truth for all dotfiles constants and paths

if [ -n "${DOTFILES_CONSTANTS_LOADED:-}" ]; then
	return 0 2>/dev/null || exit 0
fi

# =============================================================================
# PATH CALCULATIONS AND EXPORTS
# =============================================================================

# Calculate project root from constants.sh location (src/core/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
DOTFILES_ROOT="$PROJECT_ROOT/src"

# Export core paths
export PROJECT_ROOT
export DOTFILES_ROOT

# Directory paths
COMMANDS_DIR="$DOTFILES_ROOT/commands"
CORE_DIR="$DOTFILES_ROOT/core"
CONFIGS_DIR="$DOTFILES_ROOT/configs"
COMPONENTS_DIR="$DOTFILES_ROOT/components"

# Export all directory paths
export COMMANDS_DIR CORE_DIR CONFIGS_DIR COMPONENTS_DIR

# State directory (external to project)
STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/ochairo-dotfiles"
LEDGER_FILE="$STATE_DIR/symlinks.log"
LAST_SELECTION_FILE="$STATE_DIR/last-selection"

# Export state paths
export STATE_DIR LEDGER_FILE LAST_SELECTION_FILE

# Create state directory
mkdir -p "$STATE_DIR"

# =============================================================================
# COLORS AND SYMBOLS
# =============================================================================

# Colors
COLOR_RESET='\033[0m'
COLOR_RED='\033[0;31m'
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_MAGENTA='\033[0;35m'
COLOR_CYAN='\033[0;36m'
COLOR_BOLD='\033[1m'

# Export colors
export COLOR_RESET COLOR_RED COLOR_GREEN COLOR_YELLOW COLOR_BLUE COLOR_MAGENTA COLOR_CYAN COLOR_BOLD

# Symbols
SYMBOL_OK='✅'
SYMBOL_WARN='⚠️'
SYMBOL_ERR='❌'
SYMBOL_ASK='❓'
SYMBOL_RUN='🏃'
SYMBOL_DRY_RUN='🔍'
SYMBOL_INSTALL='📦'
SYMBOL_LINK='🔗'

# Export symbols
export SYMBOL_OK SYMBOL_WARN SYMBOL_ERR SYMBOL_ASK SYMBOL_RUN SYMBOL_DRY_RUN SYMBOL_INSTALL SYMBOL_LINK

# =============================================================================
# SYSTEM CONSTANTS
# =============================================================================

# OS constants
OS_MACOS=macos
OS_LINUX=linux
PROMPT_TIMEOUT=30

# Installation constants
DRY_RUN_VERBOSE=0

# Export OS constants
export OS_MACOS OS_LINUX PROMPT_TIMEOUT DRY_RUN_VERBOSE

# Mark constants as loaded
DOTFILES_CONSTANTS_LOADED=1
export DOTFILES_CONSTANTS_LOADED
