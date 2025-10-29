#!/usr/bin/env bash
# env/shell.sh - shell detection

env_shell() { [[ -n ${BASH_VERSION:-} ]] && echo bash || [[ -n ${ZSH_VERSION:-} ]] && echo zsh || [[ -n ${FISH_VERSION:-} ]] && echo fish || basename "${SHELL:-sh}"; }
env_is_shell() { [[ "$(env_shell)" == "$1" ]]; }
