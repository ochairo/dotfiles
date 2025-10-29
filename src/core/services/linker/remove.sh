#!/usr/bin/env bash
# linker/remove.sh - remove symlinks & batch removal

symlinks_remove() {
  local target="$1" component="$2" backup orig_target count=0
  [[ -L "$target" ]] || return 1
  rm "$target"
  if command -v ledger_entries >/dev/null 2>&1; then
    backup=$(ledger_entries "$component" | grep "^backup|" | grep "|${target}$" | tail -n 1 | cut -d'|' -f3)
    if [[ -n "$backup" && -e "$backup" ]]; then
      if [[ -f "${backup}.symlink_target" ]]; then
        orig_target=$(cat "${backup}.symlink_target")
        ln -sf "$orig_target" "$target"
        rm "${backup}.symlink_target"
      else
        mv "$backup" "$target"
      fi
    fi
  fi
  if command -v ledger_remove_entry >/dev/null 2>&1; then
    ledger_remove_entry "$target"
  fi
  return 0
}

symlinks_remove_all() {
  local component="$1" count=0 target
  symlinks_list "$component" | while read -r target; do
    if symlinks_remove "$target" "$component"; then
      count=$((count+1))
    fi
  done
  echo "$count"
}
