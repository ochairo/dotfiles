#!/usr/bin/env bash
# index.sh - Load all primitive utilities
# Source this file to get all primitive utilities at once

PRIMITIVES_LIB_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# Source all primitive utilities (data operations only)
# shellcheck source=./strings.sh
source "${PRIMITIVES_LIB_DIR}/strings.sh"

# shellcheck source=./arrays.sh
source "${PRIMITIVES_LIB_DIR}/arrays.sh"
