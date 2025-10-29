#!/usr/bin/env bash
# download/download.sh - Loader for download & extraction utilities

[[ -n "${DOWNLOAD_MODULE_LOADED:-}" ]] && return 0
readonly DOWNLOAD_MODULE_LOADED=1

DOWNLOAD_DIR="$(cd "$(dirname "${BASH_SOURCE[0]:-$0}")" && pwd)"

# shellcheck source=/dev/null
source "${DOWNLOAD_DIR}/fetch.sh"
# shellcheck source=/dev/null
source "${DOWNLOAD_DIR}/extract.sh"
# shellcheck source=/dev/null
source "${DOWNLOAD_DIR}/checksum.sh"
# shellcheck source=/dev/null
source "${DOWNLOAD_DIR}/combo.sh"
