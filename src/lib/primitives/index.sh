#!/usr/bin/env bash
# index.sh - Load all primitive utilities
# Source this file to get all primitive utilities at once

PRIMITIVES_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# Source all primitive utilities in dependency order
# shellcheck source=./msg.sh
source "${PRIMITIVES_LIB_DIR}/msg.sh"

# shellcheck source=./strings.sh
source "${PRIMITIVES_LIB_DIR}/strings.sh"

# shellcheck source=./arrays.sh
source "${PRIMITIVES_LIB_DIR}/arrays.sh"

# shellcheck source=./validation.sh
source "${PRIMITIVES_LIB_DIR}/validation.sh"

# shellcheck source=./errors.sh
source "${PRIMITIVES_LIB_DIR}/errors.sh"

# shellcheck source=./files.sh
source "${PRIMITIVES_LIB_DIR}/files.sh"
