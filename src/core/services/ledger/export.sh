#!/usr/bin/env bash
# ledger/export.sh - JSON export of ledger entries

ledger_export_json() {
  [[ -f "$DOTFILES_LEDGER" ]] || { echo "[]"; return 0; }
  echo "["
  local first=1 type component target source timestamp line
  while IFS='|' read -r type component target source timestamp; do
    if [[ $first -eq 1 ]]; then first=0; else echo ","; fi
    printf '  {"type":"%s","component":"%s","target":"%s","source":"%s","timestamp":"%s"}' \
      "$type" "$component" "$target" "$source" "$timestamp"
  done < "$DOTFILES_LEDGER"
  echo ""
  echo "]"
}
