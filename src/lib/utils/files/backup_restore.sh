#!/usr/bin/env bash
# files/backup_restore.sh - Backup & restore helpers

file_backup() {
    local file="$1" backup_suffix="${2:-backup}"; [[ -z $file ]] && { msg_error "file_backup requires file path"; return 1; }
    [[ -f $file ]] || { msg_error "file does not exist: $file"; return 1; }
    local ts backup_file
    ts=$(date '+%Y%m%d_%H%M%S')
    backup_file="${file}.${backup_suffix}_${ts}"
    if cp "$file" "$backup_file" 2>/dev/null; then echo "$backup_file"; else msg_error "failed to create backup of $file"; return 1; fi
}

file_restore() {
    local file="$1" pattern="${2:-backup}"; [[ -z $file ]] && { msg_error "file_restore requires file path"; return 1; }
    local backup_file
    backup_file=$(find "$(dirname "$file")" -name "$(basename "$file").${pattern}_*" -type f 2>/dev/null | sort -r | head -n1)
    [[ -n $backup_file ]] || { msg_error "no backup found for $file with pattern $pattern"; return 1; }
    cp "$backup_file" "$file" 2>/dev/null || { msg_error "failed to restore $file from $backup_file"; return 1; }
    echo "Restored $file from $backup_file"
}
