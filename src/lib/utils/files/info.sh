#!/usr/bin/env bash
# files/info.sh - File metadata utilities

file_size() { local file="$1"; [[ -n $file ]] || { msg_error "file_size requires file path"; return 1; }; [[ -f $file ]] || { msg_error "file does not exist: $file"; return 1; }; stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null; }
file_mtime() { local file="$1"; [[ -n $file ]] || { msg_error "file_mtime requires file path"; return 1; }; [[ -f $file ]] || { msg_error "file does not exist: $file"; return 1; }; stat -f%m "$file" 2>/dev/null || stat -c%Y "$file" 2>/dev/null; }
