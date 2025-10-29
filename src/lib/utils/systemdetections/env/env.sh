#!/usr/bin/env bash
# env/env.sh - loader for segmented environment utilities
[[ -n "${SYSTEM_ENV_LOADED:-}" ]] && return 0
readonly SYSTEM_ENV_LOADED=1
ENV_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"
# shellcheck source=./vars.sh
source "${ENV_DIR}/vars.sh"
# shellcheck source=./ci.sh
source "${ENV_DIR}/ci.sh"
# shellcheck source=./path.sh
source "${ENV_DIR}/path.sh"
# shellcheck source=./shell.sh
source "${ENV_DIR}/shell.sh"
# shellcheck source=./user.sh
source "${ENV_DIR}/user.sh"
# shellcheck source=./system.sh
source "${ENV_DIR}/system.sh"
# shellcheck source=./debug.sh
source "${ENV_DIR}/debug.sh"
unset ENV_DIR
