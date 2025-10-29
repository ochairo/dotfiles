#!/usr/bin/env bash
# ledger/query.sh - query & read operations

ledger_has() { local target="$1"; [[ -f "$DOTFILES_LEDGER" ]] || return 1; grep -qF "|${target}|" "$DOTFILES_LEDGER"; }
ledger_owner() { local target="$1"; [[ -f "$DOTFILES_LEDGER" ]] || return 1; grep -F "|${target}|" "$DOTFILES_LEDGER" | tail -n 1 | cut -d'|' -f2; }
ledger_entries() { local component="$1"; [[ -f "$DOTFILES_LEDGER" ]] || return 0; grep "^[^|]*|${component}|" "$DOTFILES_LEDGER"; }
ledger_targets() { local component="$1"; ledger_entries "$component" | cut -d'|' -f3; }
ledger_symlinks() { local component="$1"; [[ -f "$DOTFILES_LEDGER" ]] || return 0; grep "^symlink|${component}|" "$DOTFILES_LEDGER" | cut -d'|' -f3; }
ledger_components() { [[ -f "$DOTFILES_LEDGER" ]] || return 0; cut -d'|' -f2 "$DOTFILES_LEDGER" | sort -u; }
ledger_count() { local component="${1:-}"; [[ -f "$DOTFILES_LEDGER" ]] || { echo 0; return 0; }; if [[ -n "$component" ]]; then ledger_entries "$component" | wc -l | tr -d ' '; else wc -l < "$DOTFILES_LEDGER" | tr -d ' '; fi }
ledger_type() { local target="$1"; [[ -f "$DOTFILES_LEDGER" ]] || return 1; grep -F "|${target}|" "$DOTFILES_LEDGER" | tail -n 1 | cut -d'|' -f1; }
ledger_source() { local target="$1"; [[ -f "$DOTFILES_LEDGER" ]] || return 1; grep -F "|${target}|" "$DOTFILES_LEDGER" | tail -n 1 | cut -d'|' -f4; }
ledger_timestamp() { local target="$1"; [[ -f "$DOTFILES_LEDGER" ]] || return 1; grep -F "|${target}|" "$DOTFILES_LEDGER" | tail -n 1 | cut -d'|' -f5; }
