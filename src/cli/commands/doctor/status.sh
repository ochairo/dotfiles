#!/usr/bin/env bash
# usage: dot status [--json] [--quiet]
# summary: Deprecated. Use 'dot doctor' (includes ledger summary)
# group: deprecated
set -euo pipefail

JSON=0
while [[ $# -gt 0 ]]; do
  case $1 in
    --json) JSON=1; shift ;;
    --quiet) shift ;; # ignored in deprecated shim
    -h|--help) grep '^# usage:' "$0" | sed 's/# usage: //' ; exit 0 ;;
    *) shift ;;
  esac
done

ARGS=()
[[ $JSON == 1 ]] && ARGS+=(--json)
# shellcheck source=/dev/null
source "$COMMANDS_DIR/doctor/doctor.sh" "${ARGS[@]}"
