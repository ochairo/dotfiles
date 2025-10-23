#!/usr/bin/env bash
# filesystem.sh - Filesystem utilities
# Directory creation, PATH management, temp files

# Prevent double loading
[[ -n "${FILESYSTEM_UTILS_LOADED:-}" ]] && return 0
readonly FILESYSTEM_UTILS_LOADED=1

# Create directory with proper permissions
# Args: directory_path, permissions (default: 755)
# Returns: 0 if success, 1 otherwise
# Example: fs_mkdir "/opt/app" "775"
fs_mkdir() {
    local dir="${1}"
    local perms="${2:-755}"

    if [[ -d "$dir" ]]; then
        return 0
    fi

    mkdir -p "$dir" && chmod "$perms" "$dir"
}

# Add directory to PATH in shell RC file
# Args: directory, rc_file (default: auto-detect)
# Returns: 0 if success, 1 otherwise
# Example: fs_add_to_path "/opt/app/bin"
fs_add_to_path() {
    local dir="${1}"
    local rc_file="${2:-}"

    if [[ ! -d "$dir" ]]; then
        return 1
    fi

    # Auto-detect RC file if not provided
    if [[ -z "$rc_file" ]]; then
        if [[ -n "${ZSH_VERSION:-}" ]]; then
            rc_file="$HOME/.zshrc"
        elif [[ -n "${BASH_VERSION:-}" ]]; then
            rc_file="$HOME/.bashrc"
        else
            rc_file="$HOME/.profile"
        fi
    fi

    # Check if already in RC file
    if [[ -f "$rc_file" ]] && grep -q "PATH.*$dir" "$rc_file"; then
        return 0
    fi

    # Add to RC file
    echo "" >> "$rc_file"
    echo "# Added by installer" >> "$rc_file"
    echo "export PATH=\"$dir:\$PATH\"" >> "$rc_file"
}

# Create temporary directory
# Returns: path to temp directory
# Example: tmpdir=$(fs_mktemp)
fs_mktemp() {
    mktemp -d 2>/dev/null || mktemp -d -t 'tmpdir'
}

# Create temporary file
# Returns: path to temp file
# Example: tmpfile=$(fs_mktemp_file)
fs_mktemp_file() {
    mktemp 2>/dev/null || mktemp -t 'tmpfile'
}

# Safely remove directory
# Args: directory_path
# Returns: 0 if success
# Example: fs_remove_dir "/tmp/install"
fs_remove_dir() {
    local dir="${1}"

    if [[ -d "$dir" ]]; then
        rm -rf "$dir"
    fi
}

# Check if directory is empty
# Args: directory_path
# Returns: 0 if empty, 1 otherwise
# Example: if fs_is_empty "/opt/app"; then echo "Empty"; fi
fs_is_empty() {
    local dir="${1}"

    if [[ ! -d "$dir" ]]; then
        return 1
    fi

    [[ -z "$(ls -A "$dir")" ]]
}

# Get directory size in bytes
# Args: directory_path
# Returns: size in bytes
# Example: size=$(fs_dir_size "/opt/app")
fs_dir_size() {
    local dir="${1}"

    if [[ ! -d "$dir" ]]; then
        echo "0"
        return 1
    fi

    if command -v du >/dev/null 2>&1; then
        du -sb "$dir" 2>/dev/null | cut -f1
    else
        echo "0"
    fi
}

# Copy directory with permissions
# Args: source_dir, dest_dir
# Returns: 0 if success
# Example: fs_copy_dir "/opt/app" "/backup/app"
fs_copy_dir() {
    local src="${1}"
    local dest="${2}"

    if [[ ! -d "$src" ]]; then
        return 1
    fi

    cp -a "$src" "$dest"
}

# Make file executable
# Args: file_path
# Returns: 0 if success, 1 otherwise
# Example: fs_make_executable "/usr/local/bin/app"
fs_make_executable() {
    local file="${1}"

    if [[ ! -f "$file" ]]; then
        return 1
    fi

    chmod +x "$file"
}

# Setup cleanup trap
# Args: cleanup_function
# Example: fs_trap_cleanup "rm -rf /tmp/install-*"
fs_trap_cleanup() {
    local cleanup_cmd="${1}"
    # shellcheck disable=SC2064
    trap "$cleanup_cmd" EXIT INT TERM
}

# Check if path is absolute
# Args: path
# Returns: 0 if absolute, 1 otherwise
# Example: if fs_is_absolute "/opt/app"; then echo "Absolute"; fi
fs_is_absolute() {
    [[ "${1}" = /* ]]
}

# Get absolute path
# Args: relative_path
# Returns: absolute path
# Example: abs=$(fs_absolute "../app")
fs_absolute() {
    local path="${1}"

    if fs_is_absolute "$path"; then
        echo "$path"
    else
        echo "$(cd "$(dirname "$path")" && pwd)/$(basename "$path")"
    fi
}
