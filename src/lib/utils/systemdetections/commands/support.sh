#!/usr/bin/env bash
# commands/support.sh - flag support tests

cmd_supports() { local cmd="$1" flag="$2"; cmd_exists "$cmd" || return 1; "$cmd" "$flag" >/dev/null 2>&1; }
