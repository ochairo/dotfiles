#!/usr/bin/env bash
# download/combo.sh - Combined download + extract

download_and_extract() {
    local url="$1" dest="$2" archive_name="${3:-$(basename "$url")}" tmpdir archive
    tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'download')
    archive="$tmpdir/$archive_name"
    if download_file "$url" "$archive" && download_extract "$archive" "$dest"; then rm -rf "$tmpdir"; return 0; fi
    rm -rf "$tmpdir"; return 1
}
