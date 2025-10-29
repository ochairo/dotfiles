#!/usr/bin/env bash
# files/files.sh - Loader for generic file operations

[[ -n "${FILES_MODULE_LOADED:-}" ]] && return 0
readonly FILES_MODULE_LOADED=1

FILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# shellcheck source=/dev/null
source "${FILES_DIR}/backup_restore.sh"
# shellcheck source=/dev/null
source "${FILES_DIR}/copy_move.sh"
# shellcheck source=/dev/null
source "${FILES_DIR}/perms.sh"
# shellcheck source=/dev/null
source "${FILES_DIR}/temp.sh"
# shellcheck source=/dev/null
source "${FILES_DIR}/predicates.sh"
# shellcheck source=/dev/null
source "${FILES_DIR}/info.sh"
 # Consolidated filesystem helpers
# shellcheck source=/dev/null
source "${FILES_DIR}/fs.sh"
