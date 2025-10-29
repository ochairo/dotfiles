#!/usr/bin/env bash
# doctor/parts/args.sh - Argument parsing for doctor

doctor_parse_args() {
  JSON=0; STRICT=0; COMP_FILTER=""; local arg
  while [[ $# -gt 0 ]]; do
    case $1 in
      --components) COMP_FILTER="$2"; shift 2;;
      --json) JSON=1; shift;;
      --strict) STRICT=1; shift;;
      --help|-h) grep '^# usage:' "$0" | sed 's/# usage: //' ; exit 0;;
      *) if declare -F msg_warn >/dev/null 2>&1; then msg_warn "Unknown flag $1"; else echo "[WARN] Unknown flag $1" >&2; fi; shift;;
    esac
  done
}
