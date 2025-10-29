#!/usr/bin/env bash
# download/checksum.sh - Checksum verification

download_verify_checksum() {
    local file="$1" expected="$2" algo="${3:-sha256}" actual
    [[ -f $file ]] || return 1
    case "$algo" in
        sha256)
            if command -v sha256sum >/dev/null 2>&1; then actual=$(sha256sum "$file" | cut -d' ' -f1); elif command -v shasum >/dev/null 2>&1; then actual=$(shasum -a 256 "$file" | cut -d' ' -f1); else return 1; fi ;;
        sha1)
            if command -v sha1sum >/dev/null 2>&1; then actual=$(sha1sum "$file" | cut -d' ' -f1); elif command -v shasum >/dev/null 2>&1; then actual=$(shasum -a 1 "$file" | cut -d' ' -f1); else return 1; fi ;;
        md5)
            if command -v md5sum >/dev/null 2>&1; then actual=$(md5sum "$file" | cut -d' ' -f1); elif command -v md5 >/dev/null 2>&1; then actual=$(md5 -q "$file"); else return 1; fi ;;
        *) return 1 ;;
    esac
    [[ $actual == "$expected" ]]
}
