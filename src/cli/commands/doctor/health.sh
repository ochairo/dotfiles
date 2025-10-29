#!/usr/bin/env bash
# usage: dot health [--only comp1,comp2] [--json] [--strict]
# summary: Deprecated. Use 'dot doctor --components' (health subset)
# group: deprecated
set -euo pipefail

ONLY="" JSON=0 STRICT=0
ARGS=()
while [[ $# -gt 0 ]]; do
  case $1 in
    --only)
      ONLY="$2"; shift 2 ;;
    --json) JSON=1; shift ;;
    --strict) STRICT=1; shift ;;
    -h|--help)
      grep '^# usage:' "$0" | sed 's/# usage: //' ; exit 0 ;;
    *) ARGS+=("$1"); shift ;;
  esac
done

COMP_FLAG=()
[[ -n $ONLY ]] && COMP_FLAG=(--components "$ONLY")
JSON_FLAG=()
[[ $JSON == 1 ]] && JSON_FLAG=(--json)
STRICT_FLAG=()
[[ $STRICT == 1 ]] && STRICT_FLAG=(--strict)

# shellcheck source=/dev/null
source "$COMMANDS_DIR/doctor/doctor.sh" "${COMP_FLAG[@]}" "${JSON_FLAG[@]}" "${STRICT_FLAG[@]}" "${ARGS[@]}"
