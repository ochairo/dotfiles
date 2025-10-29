#!/usr/bin/env bash
# strings/split.sh - delimiter-based splitting

string_split() {
  local string="$1" delimiter="$2" IFS="$delimiter" parts
  [[ -n "$string" ]] || return 0
  read -ra parts <<< "$string"
  printf '%s\n' "${parts[@]}"
}
