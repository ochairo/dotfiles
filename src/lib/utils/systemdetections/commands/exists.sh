#!/usr/bin/env bash
# commands/exists.sh - existence & availability predicates

cmd_exists() { command -v "$1" >/dev/null 2>&1; }
cmd_wait_for() { local cmd="$1" timeout="${2:-30}" elapsed=0; while ! cmd_exists "$cmd"; do (( elapsed >= timeout )) && return 1; sleep 1; ((elapsed++)); done; }
cmd_all_exist() { local missing=0 c; for c in "$@"; do cmd_exists "$c" || missing=1; done; return $missing; }
cmd_any_exist() { local c; for c in "$@"; do cmd_exists "$c" && return 0; done; return 1; }
cmd_first_available() { local c; for c in "$@"; do cmd_exists "$c" && { echo "$c"; return 0; }; done; return 1; }
