#!/usr/bin/env bash
# download/extract.sh - Archive extraction

download_extract() {
    local archive="$1" dest="${2:-.}"; [[ -f $archive ]] || return 1; mkdir -p "$dest"
    case "$archive" in
        *.tar.gz|*.tgz) tar -xzf "$archive" -C "$dest" ;;
        *.tar.bz2|*.tbz2) tar -xjf "$archive" -C "$dest" ;;
        *.tar.xz|*.txz) tar -xJf "$archive" -C "$dest" ;;
        *.tar) tar -xf "$archive" -C "$dest" ;;
        *.zip) unzip -q "$archive" -d "$dest" ;;
        *.gz) gunzip -c "$archive" > "$dest/$(basename "${archive%.gz}")" ;;
        *) return 1 ;;
    esac
}
