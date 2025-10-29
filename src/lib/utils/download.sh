#!/usr/bin/env bash
# download.sh - Download and extraction utilities
# Handle file downloads, archives, and checksums

# Prevent double loading
[[ -n "${DOWNLOAD_UTILS_LOADED:-}" ]] && return 0
readonly DOWNLOAD_UTILS_LOADED=1

# Download file with retries
# Args: url, output_path, max_retries (default: 3)
# Returns: 0 if success, 1 otherwise
# Example: download_file "https://example.com/file" "/tmp/file"
download_file() {
    local url="${1}"
    local output="${2}"
    local max_retries="${3:-3}"

    # Internal download function (no retry logic here)
    _do_download() {
        if cmd_exists "curl"; then
            curl -fsSL -o "$output" "$url"
        elif cmd_exists "wget"; then
            wget -q -O "$output" "$url"
        else
            return 1
        fi
    }

    # Use retry utility if available, otherwise direct download
    if command -v retry >/dev/null 2>&1; then
        retry "$max_retries" _do_download
    else
        _do_download
    fi
}

# Extract archive based on extension
# Args: archive_path, destination (default: current directory)
# Returns: 0 if success, 1 otherwise
# Example: download_extract "/tmp/archive.tar.gz" "/opt/app"
download_extract() {
    local archive="${1}"
    local dest="${2:-.}"

    if [[ ! -f "$archive" ]]; then
        return 1
    fi

    mkdir -p "$dest"

    case "$archive" in
        *.tar.gz|*.tgz)
            tar -xzf "$archive" -C "$dest"
            ;;
        *.tar.bz2|*.tbz2)
            tar -xjf "$archive" -C "$dest"
            ;;
        *.tar.xz|*.txz)
            tar -xJf "$archive" -C "$dest"
            ;;
        *.tar)
            tar -xf "$archive" -C "$dest"
            ;;
        *.zip)
            unzip -q "$archive" -d "$dest"
            ;;
        *.gz)
            gunzip -c "$archive" > "$dest/$(basename "${archive%.gz}")"
            ;;
        *)
            return 1
            ;;
    esac
}

# Verify file checksum
# Args: file_path, expected_checksum, algorithm (default: sha256)
# Returns: 0 if match, 1 otherwise
# Example: download_verify_checksum "/tmp/file" "abc123..." "sha256"
download_verify_checksum() {
    local file="${1}"
    local expected="${2}"
    local algo="${3:-sha256}"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    local actual
    case "$algo" in
        sha256)
            if command -v sha256sum >/dev/null 2>&1; then
                actual=$(sha256sum "$file" | cut -d' ' -f1)
            elif command -v shasum >/dev/null 2>&1; then
                actual=$(shasum -a 256 "$file" | cut -d' ' -f1)
            else
                return 1
            fi
            ;;
        sha1)
            if command -v sha1sum >/dev/null 2>&1; then
                actual=$(sha1sum "$file" | cut -d' ' -f1)
            elif command -v shasum >/dev/null 2>&1; then
                actual=$(shasum -a 1 "$file" | cut -d' ' -f1)
            else
                return 1
            fi
            ;;
        md5)
            if command -v md5sum >/dev/null 2>&1; then
                actual=$(md5sum "$file" | cut -d' ' -f1)
            elif command -v md5 >/dev/null 2>&1; then
                actual=$(md5 -q "$file")
            else
                return 1
            fi
            ;;
        *)
            return 1
            ;;
    esac

    [[ "$actual" == "$expected" ]]
}

# Download and extract in one step
# Args: url, destination, archive_name (optional)
# Returns: 0 if success, 1 otherwise
# Example: download_and_extract "https://example.com/app.tar.gz" "/opt/app"
download_and_extract() {
    local url="${1}"
    local dest="${2}"
    local archive_name="${3:-$(basename "$url")}"
    local tmpdir

    tmpdir=$(mktemp -d 2>/dev/null || mktemp -d -t 'download')
    local archive="$tmpdir/$archive_name"

    if download_file "$url" "$archive"; then
        if download_extract "$archive" "$dest"; then
            rm -rf "$tmpdir"
            return 0
        fi
    fi

    rm -rf "$tmpdir"
    return 1
}
