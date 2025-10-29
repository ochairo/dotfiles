#!/usr/bin/env bash
# linker/list.sh - listing & batch operations

symlinks_list() { local component="$1"; command -v ledger_symlinks >/dev/null 2>&1 && ledger_symlinks "$component"; }

symlinks_is_managed() { local path="$1"; command -v ledger_has >/dev/null 2>&1 && ledger_has "$path"; }

symlinks_target() { local path="$1"; [[ -L "$path" ]] || return 1; readlink "$path"; }

symlinks_batch_create() {
  local source_dir="$1" target_dir="$2" component="$3" pattern="${4:-.gitconfig}" file basename
  [[ -d "$source_dir" ]] || return 1
  find "$source_dir" -maxdepth 1 -name "$pattern" -type f | while read -r file; do
    basename=$(basename "$file")
    symlinks_create "$file" "$target_dir/$basename" "$component"
  done
}

symlinks_repair() {
  local component="$1" count=0 target source
  if command -v ledger_entries >/dev/null 2>&1; then
    ledger_entries "$component" | grep "^symlink|" | while IFS='|' read -r _ _ target source _; do
      if [[ ! -e "$target" && -e "$source" ]]; then
        if symlinks_create "$source" "$target" "$component"; then
          count=$((count+1))
        fi
      fi
    done
  fi
  echo "$count"
}
