#!/usr/bin/env bash
# linker/backup.sh - backup existing path before symlink replacement

# Use repository .tmp/backup for symlink backups
: "${DOTFILES_STATE_DIR:=${DOTFILES_ROOT}/.tmp}"
if [[ ! -d "$DOTFILES_STATE_DIR" ]]; then
  mkdir -p "$DOTFILES_STATE_DIR" || echo "Failed to create state dir: $DOTFILES_STATE_DIR" >&2
fi
: "${DOTFILES_BACKUP_DIR:=${DOTFILES_STATE_DIR}/backup}"

symlinks_backup() {
  local path="$1"
  local backup_dir="$DOTFILES_BACKUP_DIR"
  local timestamp backup_path rel_path
  [[ ! -e "$path" ]] && return 0
  timestamp=$(date +%Y%m%d_%H%M%S)
  mkdir -p "$backup_dir"
  rel_path="${path#"$HOME"/}"
  backup_path="$backup_dir/${rel_path}.${timestamp}"
  mkdir -p "$(dirname "$backup_path")"
  if [[ -L "$path" ]]; then
    readlink "$path" > "${backup_path}.symlink_target"
    rm "$path"
  else
    mv "$path" "$backup_path"
  fi
  echo "$backup_path"
}
