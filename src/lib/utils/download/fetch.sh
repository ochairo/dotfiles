#!/usr/bin/env bash
# download/fetch.sh - Download with retry

download_file() {
    local url="$1" output="$2" max_retries="${3:-3}"
    _download_do() {
        if cmd_exists curl; then curl -fsSL -o "$output" "$url"; elif cmd_exists wget; then wget -q -O "$output" "$url"; else return 1; fi
    }
    if command -v retry >/dev/null 2>&1; then retry "$max_retries" _download_do; else _download_do; fi
}
