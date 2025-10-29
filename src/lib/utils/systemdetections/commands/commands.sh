#!/usr/bin/env bash
# commands/commands.sh - loader for command utilities
[[ -n "${COMMAND_DETECTION_LOADED:-}" ]] && return 0
readonly COMMAND_DETECTION_LOADED=1
CMD_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=./exists.sh
source "${CMD_DIR}/exists.sh"
# shellcheck source=./version.sh
source "${CMD_DIR}/version.sh"
# shellcheck source=./support.sh
source "${CMD_DIR}/support.sh"
# shellcheck source=./path.sh
source "${CMD_DIR}/path.sh"
unset CMD_DIR
