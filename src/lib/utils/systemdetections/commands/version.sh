#!/usr/bin/env bash
# commands/version.sh - version retrieval

cmd_version() { local cmd="$1" flag="${2:---version}"; cmd_exists "$cmd" || return 1; "$cmd" "$flag" 2>&1 | head -n 1; }
