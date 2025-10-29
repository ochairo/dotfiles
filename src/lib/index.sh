#!/usr/bin/env bash
# index.sh - Load all libraries
# Source this file to get all libraries at once

LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# Verify library directory exists
if [[ ! -d "$LIB_DIR" || ! -f "$LIB_DIR/primitives/index.sh" ]]; then
    echo "Error: Library directory not found or invalid: $LIB_DIR" >&2
    return 1
fi

# Load foundational modules first (no dependencies)
source "${LIB_DIR}/constants.sh"
source "${LIB_DIR}/colors.sh"

# Load all utility libraries
source "${LIB_DIR}/primitives/index.sh"
source "${LIB_DIR}/ui/index.sh"
source "${LIB_DIR}/utils/index.sh"

# (Removed options.sh legacy loader; DOT_OPT_* system deprecated)
