#!/usr/bin/env bash
# env/path.sh - PATH operations

env_path_contains() { local dir="$1"; [[ ":$PATH:" == *":$dir:"* ]]; }
env_path_add() { local dir="$1" pos="${2:-prepend}"; [[ -d "$dir" ]] || return 1; env_path_contains "$dir" && return 0; if [[ "$pos" == append ]]; then export PATH="$PATH:$dir"; else export PATH="$dir:$PATH"; fi }
env_path_remove() { local dir="$1" new_path="" IFS=":"; for p in $PATH; do [[ "$p" == "$dir" ]] && continue; new_path+="${new_path:+:}$p"; done; export PATH="$new_path"; }
