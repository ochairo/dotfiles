#!/usr/bin/env bash
# validation/choice.sh - Choice membership

validate_choice() { local value="$1"; shift; local c; for c in "$@"; do [[ $value == "$c" ]] && return 0; done; return 1; }
