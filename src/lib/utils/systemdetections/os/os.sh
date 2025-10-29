#!/usr/bin/env bash
# os/os.sh - loader for OS detection utilities
[[ -n "${SYSTEM_OS_LOADED:-}" ]] && return 0
readonly SYSTEM_OS_LOADED=1
OS_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=./detect.sh
source "${OS_DIR}/detect.sh"
# shellcheck source=./distro.sh
source "${OS_DIR}/distro.sh"
# shellcheck source=./platform.sh
source "${OS_DIR}/platform.sh"
# shellcheck source=./version.sh
source "${OS_DIR}/version.sh"
# shellcheck source=./arch.sh
source "${OS_DIR}/arch.sh"
# shellcheck source=./info.sh
source "${OS_DIR}/info.sh"
unset OS_DIR
