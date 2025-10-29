#!/usr/bin/env bash
# term/term.sh - loader for segmented terminal utilities
[[ -n "${SYSTEM_TERM_LOADED:-}" ]] && return 0
readonly SYSTEM_TERM_LOADED=1
TERM_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"
# Global capability flags
TERM_TRUECOLOR=0 TERM_256COLOR=0 TERM_EMOJI=0 TERM_INTERACTIVE=0
export TERM_TRUECOLOR TERM_256COLOR TERM_EMOJI TERM_INTERACTIVE
# shellcheck source=./detect.sh
source "${TERM_DIR}/detect.sh"
# shellcheck source=./caps.sh
source "${TERM_DIR}/caps.sh"
# shellcheck source=./cursor.sh
source "${TERM_DIR}/cursor.sh"
# shellcheck source=./name.sh
source "${TERM_DIR}/name.sh"
unset TERM_DIR
