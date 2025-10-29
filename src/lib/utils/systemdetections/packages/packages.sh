#!/usr/bin/env bash
# packages/packages.sh - loader for segmented package manager utilities
[[ -n "${SYSTEM_PACKAGES_LOADED:-}" ]] && return 0
readonly SYSTEM_PACKAGES_LOADED=1
PKG_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=./detect.sh
source "${PKG_DIR}/detect.sh"
# shellcheck source=./commands.sh
source "${PKG_DIR}/commands.sh"
# shellcheck source=./status.sh
source "${PKG_DIR}/status.sh"
unset PKG_DIR
