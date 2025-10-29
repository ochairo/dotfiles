#!/usr/bin/env bash
# files/temp.sh - Temporary file creation

file_temp() {
    local prefix="${1:-tmp}" suffix="${2}" temp_dir="${3:-${TEMP_DIR:-./.tmp}}"
    [[ -d $temp_dir ]] || mkdir -p "$temp_dir"
    local rid; rid=$(date +%s)$$
    local temp_file="${temp_dir}/${prefix}.${rid}${suffix}"
    touch "$temp_file" 2>/dev/null || { msg_error "failed to create temporary file"; return 1; }
    echo "$temp_file"
}
