#!/usr/bin/env bash
# init/parse.sh - Argument parsing for dot init

init_parse_args() {
  NO_WIZARD=0 REPEAT_MODE=0 DRY_RUN=0 PASSTHRU=()
  while [[ $# -gt 0 ]]; do
    case $1 in
      --no-wizard) NO_WIZARD=1; shift;;
      --repeat) REPEAT_MODE=1; shift;;
      --dry-run) DRY_RUN=1; PASSTHRU+=("--dry-run"); shift;;
      --dry-run-verbose) DRY_RUN=1; PASSTHRU+=("--dry-run-verbose"); shift;;
      --help|-h) grep '^# usage:' "$0" | sed 's/# usage: //' ; exit 0;;
      *) PASSTHRU+=("$1"); shift;;
    esac
  done
}
