#!/usr/bin/env bash
# files/copy_move.sh - Safe copy & move operations

file_copy_safe() {
    local source="$1" dest="$2"
    [[ -n $source && -n $dest ]] || { msg_error "file_copy_safe requires source and destination"; return 1; }
    [[ -f $source ]] || { msg_error "source file does not exist: $source"; return 1; }
    local dest_dir; dest_dir=$(dirname "$dest"); [[ -d $dest_dir ]] || mkdir -p "$dest_dir"
    if cp "$source" "$dest" 2>/dev/null; then
        local source_size dest_size
        source_size=$(stat -f%z "$source" 2>/dev/null || stat -c%s "$source" 2>/dev/null)
        dest_size=$(stat -f%z "$dest" 2>/dev/null || stat -c%s "$dest" 2>/dev/null)
        if [[ $source_size == "$dest_size" ]]; then return 0; fi
        msg_error "copy verification failed - size mismatch"; rm -f "$dest"; return 1
    fi
    msg_error "failed to copy $source to $dest"; return 1
}

file_move_safe() {
    local source="$1" dest="$2"
    [[ -n $source && -n $dest ]] || { msg_error "file_move_safe requires source and destination"; return 1; }
    [[ -f $source ]] || { msg_error "source file does not exist: $source"; return 1; }
    if file_copy_safe "$source" "$dest"; then
        rm "$source" 2>/dev/null || { msg_error "failed to remove source file after copy: $source"; return 1; }
        return 0
    fi
    return 1
}
