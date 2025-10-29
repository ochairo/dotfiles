#!/usr/bin/env bash
# files/perms.sh - Permission helpers

file_chmod_safe() {
    local file="$1" permissions="$2" create_backup="${3:-true}"
    [[ -n $file && -n $permissions ]] || { msg_error "file_chmod_safe requires file and permissions"; return 1; }
    [[ -f $file ]] || { msg_error "file does not exist: $file"; return 1; }
    if [[ $create_backup == true ]]; then
        local current_perms; current_perms=$(stat -f%Mp%Lp "$file" 2>/dev/null || stat -c%a "$file" 2>/dev/null)
        echo "$current_perms" >"${file}.perms_backup" 2>/dev/null || true
    fi
    chmod "$permissions" "$file" 2>/dev/null || { msg_error "failed to change permissions on $file"; return 1; }
}
