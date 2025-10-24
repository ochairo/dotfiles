#!/usr/bin/env bash
# index.sh - Load all utilities
# Source this file to get all utilities at once

UTILITIES_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# Load system detection utilities first (needed by others)
source "${UTILITIES_LIB_DIR}/systemdetections/index.sh"

# Load validation and file utilities (needed by others)
source "${UTILITIES_LIB_DIR}/validation.sh"
source "${UTILITIES_LIB_DIR}/files.sh"

# Load core utility modules
source "${UTILITIES_LIB_DIR}/retry.sh"
source "${UTILITIES_LIB_DIR}/filesystem.sh"
source "${UTILITIES_LIB_DIR}/download.sh"
source "${UTILITIES_LIB_DIR}/symlinks.sh"
source "${UTILITIES_LIB_DIR}/parallel.sh"
source "${UTILITIES_LIB_DIR}/transactional.sh"
