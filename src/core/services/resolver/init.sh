#!/usr/bin/env bash
# resolver init - guard
[[ -n "${DOTFILES_RESOLVER_SEGMENTS_LOADED:-}" ]] && return 0
readonly DOTFILES_RESOLVER_SEGMENTS_LOADED=1
