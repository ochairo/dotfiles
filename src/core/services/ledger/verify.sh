#!/usr/bin/env bash
# ledger/verify.sh - verification of ledger tracked targets

ledger_verify() {
  [[ -f "$DOTFILES_LEDGER" ]] || return 0
  local type component target source timestamp
  while IFS='|' read -r type component target source timestamp; do
    [[ -e "$target" ]] || echo "$target (from $component)"
  done < "$DOTFILES_LEDGER"
}
