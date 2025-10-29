#!/usr/bin/env bash
# index.sh - Load all system detection utilities
# Source this file to get all system detection utilities at once

SYSTEMDETECTIONS_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# Load system detection utilities
source "${SYSTEMDETECTIONS_LIB_DIR}/commands/commands.sh"
source "${SYSTEMDETECTIONS_LIB_DIR}/os/os.sh"
source "${SYSTEMDETECTIONS_LIB_DIR}/packages/packages.sh"
source "${SYSTEMDETECTIONS_LIB_DIR}/term/term.sh"
source "${SYSTEMDETECTIONS_LIB_DIR}/env/env.sh"
