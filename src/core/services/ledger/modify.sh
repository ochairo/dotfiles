#!/usr/bin/env bash
# ledger/modify.sh - removal & maintenance operations

ledger_remove() {
  local component="$1" temp
  [[ -f "$DOTFILES_LEDGER" ]] || return 0
  temp=$(mktemp)
  grep -v "^[^|]*|${component}|" "$DOTFILES_LEDGER" > "$temp" || true
  mv "$temp" "$DOTFILES_LEDGER"
}

ledger_remove_entry() {
  local target="$1" temp
  [[ -f "$DOTFILES_LEDGER" ]] || return 0
  temp=$(mktemp)
  grep -vF "|${target}|" "$DOTFILES_LEDGER" > "$temp" || true
  mv "$temp" "$DOTFILES_LEDGER"
}

ledger_compact() {
  local temp
  [[ -f "$DOTFILES_LEDGER" ]] || return 0
  temp=$(mktemp)
  awk -F'|' '{ key=$2"|"$3; entries[key]=$0 } END { for (k in entries) print entries[k] }' "$DOTFILES_LEDGER" | sort > "$temp"
  mv "$temp" "$DOTFILES_LEDGER"
}

ledger_backup() {
  [[ -f "$DOTFILES_LEDGER" ]] || return 0
  local backup="${DOTFILES_LEDGER}.backup.$(date +%Y%m%d_%H%M%S)"
  cp "$DOTFILES_LEDGER" "$backup"
  echo "$backup"
}
