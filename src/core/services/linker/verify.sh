#!/usr/bin/env bash
# linker/verify.sh - symlink verification & repair

symlinks_verify() {
  local target="$1" expected_source="$2" actual_source
  [[ -L "$target" ]] || return 1
  actual_source=$(readlink "$target")
  [[ "$actual_source" == "$expected_source" ]]
}

symlinks_verify_all() {
  local component="$1" target
  if command -v ledger_symlinks >/dev/null 2>&1; then
    ledger_symlinks "$component" | while read -r target; do
      if [[ ! -L "$target" ]]; then
        echo "$target (missing)"
      elif [[ ! -e "$target" ]]; then
        echo "$target (broken)"
      fi
    done
  fi
}
