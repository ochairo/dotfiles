#!/usr/bin/env bash
# linker/create.sh - create symlink with backup + ledger tracking

symlinks_create() {
  local source="$1" target="$2" component="$3" backup current_target
  [[ -e "$source" ]] || return 1
  if [[ -e "$target" || -L "$target" ]]; then
    if [[ -L "$target" ]]; then
      current_target=$(readlink "$target")
      [[ "$current_target" == "$source" ]] && return 0
    fi
    backup=$(symlinks_backup "$target")
    if [[ -n "$backup" && $(command -v ledger_add) ]]; then
      ledger_add "backup" "$component" "$backup" "$target"
    fi
  fi
  mkdir -p "$(dirname "$target")"
  if ln -sf "$source" "$target"; then
    if command -v ledger_add >/dev/null 2>&1; then
      ledger_add "symlink" "$component" "$target" "$source"
    fi
    return 0
  fi
  return 1
}
