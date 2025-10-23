#!/usr/bin/env bash
# index.sh - Load all user interface utilities
# Source this file to get all user interface utilities at once

USERINTERFACES_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# Load user interaction functions
source "${USERINTERFACES_LIB_DIR}/input.sh"
source "${USERINTERFACES_LIB_DIR}/select.sh"
source "${USERINTERFACES_LIB_DIR}/multiselect.sh"
