#!/usr/bin/env bash
# linker/linker.sh - loader for symlink management (segmented)
[[ -n "${DOTFILES_SYMLINKS_LOADED:-}" ]] && return 0
readonly DOTFILES_SYMLINKS_LOADED=1
LINKER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"

# Segment sources
# shellcheck source=./backup.sh
source "${LINKER_DIR}/backup.sh"
# shellcheck source=./create.sh
source "${LINKER_DIR}/create.sh"
# shellcheck source=./remove.sh
source "${LINKER_DIR}/remove.sh"
# shellcheck source=./verify.sh
source "${LINKER_DIR}/verify.sh"
# shellcheck source=./list.sh
source "${LINKER_DIR}/list.sh"

unset LINKER_DIR
