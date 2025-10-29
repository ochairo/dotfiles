#!/usr/bin/env bash
# register/register.sh loader - segmented component registry modules internalized
[[ -n "${DOTFILES_COMPONENTS_LOADED:-}" ]] && return 0
readonly DOTFILES_COMPONENTS_LOADED=1
_register_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"
source "${_register_dir}/init.sh"
source "${_register_dir}/paths.sh"
source "${_register_dir}/list.sh"
source "${_register_dir}/fields.sh"
source "${_register_dir}/relations.sh"
source "${_register_dir}/flags.sh"
source "${_register_dir}/health.sh"
source "${_register_dir}/filter.sh"
unset _register_dir
