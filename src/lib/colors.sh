#!/usr/bin/env bash
# colors.sh - Simple ANSI color definitions
# Reusable across any shell script project

# Prevent double loading
[[ -n "${COLORS_LOADED:-}" ]] && return 0
readonly COLORS_LOADED=1

# Basic ANSI color codes (work everywhere)
# shellcheck disable=SC2034  # These variables are used by files that source this
readonly C_RESET='\033[0m'
# shellcheck disable=SC2034
readonly C_RED='\033[0;31m'
# shellcheck disable=SC2034
readonly C_GREEN='\033[0;32m'
# shellcheck disable=SC2034
readonly C_YELLOW='\033[1;33m'
# shellcheck disable=SC2034
readonly C_BLUE='\033[0;34m'
# shellcheck disable=SC2034
readonly C_PURPLE='\033[0;35m'
# shellcheck disable=SC2034
readonly C_CYAN='\033[0;36m'
# shellcheck disable=SC2034
readonly C_WHITE='\033[1;37m'
# shellcheck disable=SC2034
readonly C_BOLD='\033[1m'
# shellcheck disable=SC2034
readonly C_DIM='\033[2m'
