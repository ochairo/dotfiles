#!/usr/bin/env bash
# constants.sh - Simple shell constants
# Reusable across any shell script project (macOS and Linux compatible)
# shellcheck disable=SC2034  # Variables are used by files that source this

# Prevent double loading
[[ -n "${CONSTANTS_LOADED:-}" ]] && return 0
readonly CONSTANTS_LOADED=1

# Essential exit codes
readonly EXIT_SUCCESS=0
readonly EXIT_ERROR=1
readonly EXIT_USAGE=2

# Essential paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR
CURRENT_DIR="$(pwd)"
readonly CURRENT_DIR
readonly USER_HOME="${HOME:-$(eval echo ~"${USER}")}"

# Basic OS detection
OS_TYPE="$(uname -s)"
readonly OS_TYPE
IS_MACOS=$([[ "$OS_TYPE" == "Darwin" ]] && echo "true" || echo "false")
readonly IS_MACOS
IS_LINUX=$([[ "$OS_TYPE" == "Linux" ]] && echo "true" || echo "false")
readonly IS_LINUX

# Common directories (XDG compliant)
readonly CONFIG_DIR="${XDG_CONFIG_HOME:-$USER_HOME/.config}"
readonly DATA_DIR="${XDG_DATA_HOME:-$USER_HOME/.local/share}"
readonly CACHE_DIR="${XDG_CACHE_HOME:-$USER_HOME/.cache}"

# Basic tool detection
HAS_BREW=$(command -v brew >/dev/null 2>&1 && echo "true" || echo "false")
readonly HAS_BREW
HAS_APT=$(command -v apt >/dev/null 2>&1 && echo "true" || echo "false")
readonly HAS_APT
HAS_GIT=$(command -v git >/dev/null 2>&1 && echo "true" || echo "false")
readonly HAS_GIT
