#!/usr/bin/env bash
# index.sh - Load all utilities
# Source this file to get all utilities at once

UTILITIES_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# Load I/O utilities first (needed by everything)
source "${UTILITIES_LIB_DIR}/msg/msg.sh"
source "${UTILITIES_LIB_DIR}/errors/errors.sh"

# Load system detection utilities (needed by others)
source "${UTILITIES_LIB_DIR}/systemdetections/index.sh"

# Load validation and file utilities (needed by others)
source "${UTILITIES_LIB_DIR}/validation/validation.sh"
source "${UTILITIES_LIB_DIR}/files/files.sh"
if [[ -f "${UTILITIES_LIB_DIR}/config/paths.sh" ]]; then
	# shellcheck source=/dev/null
	source "${UTILITIES_LIB_DIR}/config/paths.sh"
fi

# Load core utility modules
source "${UTILITIES_LIB_DIR}/retry.sh"
# Filesystem helpers now consolidated under files/fs.sh (loaded via files/files.sh)
source "${UTILITIES_LIB_DIR}/download/download.sh"
source "${UTILITIES_LIB_DIR}/symlinks.sh"
source "${UTILITIES_LIB_DIR}/parallel/parallel.sh"
if [[ -f "${UTILITIES_LIB_DIR}/transactional/transactional.sh" ]]; then
	# shellcheck source=/dev/null
	source "${UTILITIES_LIB_DIR}/transactional/transactional.sh"
fi
