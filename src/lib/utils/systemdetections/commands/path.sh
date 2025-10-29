#!/usr/bin/env bash
# commands/path.sh - command path resolution

cmd_path() { local cmd="$1"; cmd_exists "$cmd" || return 1; command -v "$cmd"; }
