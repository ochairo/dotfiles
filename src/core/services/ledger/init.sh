#!/usr/bin/env bash
# ledger/init.sh - initialization & add operations

ledger_init() { [[ -f "$DOTFILES_LEDGER" ]] || touch "$DOTFILES_LEDGER"; }

ledger_add() {
  local type="$1" component="$2" target="$3" source="${4:-}" timestamp
  ledger_init
  timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%d %H:%M:%S")
  printf '%s|%s|%s|%s|%s\n' "$type" "$component" "$target" "$source" "$timestamp" >> "$DOTFILES_LEDGER"
}
