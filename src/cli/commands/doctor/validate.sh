#!/usr/bin/env bash
# usage: dot validate [--components a,b] [--json] [--strict]
# summary: Deprecated. Use 'dot doctor --strict' (includes validation)
# group: deprecated
set -euo pipefail

COMP="" JSON=0 STRICT=0
while [[ $# -gt 0 ]]; do
  case $1 in
    --component|--components)
      COMP="$2"; shift 2 ;;
    --json) JSON=1; shift ;;
    --strict) STRICT=1; shift ;;
    -h|--help) grep '^# usage:' "$0" | sed 's/# usage: //' ; exit 0 ;;
    *) shift ;;
  esac
done

COMP_FLAG=()
[[ -n $COMP ]] && COMP_FLAG=(--components "$COMP")
JSON_FLAG=()
[[ $JSON == 1 ]] && JSON_FLAG=(--json)
STRICT_FLAG=(--strict)
[[ $STRICT == 1 ]] || STRICT_FLAG=()

# shellcheck source=/dev/null
source "$COMMANDS_DIR/doctor/doctor.sh" "${COMP_FLAG[@]}" "${JSON_FLAG[@]}" "${STRICT_FLAG[@]}"

# UI file length enforcement (non-fatal unless strict)
if [[ -f "$DOTFILES_ROOT/scripts/validate_ui_lengths.sh" ]]; then
  if ! bash "$DOTFILES_ROOT/scripts/validate_ui_lengths.sh"; then
    if [[ $STRICT == 1 ]]; then
      echo "UI length validation failed (strict mode)" >&2
      exit 1
    else
      echo "UI length validation warning (non-strict)" >&2
    fi
  fi
fi
