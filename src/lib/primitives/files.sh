#!/usr/bin/env bash
# files.sh - Generic file operations
# Reusable across any shell script project (macOS and Linux compatible)
# shellcheck disable=SC2034  # Variables are used by files that source this

# Prevent double loading
[[ -n "${FILES_LOADED:-}" ]] && return 0
readonly FILES_LOADED=1

# Create a backup of a file with timestamp
file_backup() {
    local file="${1}"
    local backup_suffix="${2:-backup}"

    [[ -z "$file" ]] && { echo "Error: file_backup requires file path" >&2; return 1; }
    [[ ! -f "$file" ]] && { echo "Error: file does not exist: $file" >&2; return 1; }

    local timestamp
    timestamp=$(date '+%Y%m%d_%H%M%S')
    local backup_file="${file}.${backup_suffix}_${timestamp}"

    if cp "$file" "$backup_file" 2>/dev/null; then
        echo "$backup_file"
        return 0
    else
        echo "Error: failed to create backup of $file" >&2
        return 1
    fi
}

# Restore a file from its most recent backup
file_restore() {
    local file="${1}"
    local backup_pattern="${2:-backup}"

    [[ -z "$file" ]] && { echo "Error: file_restore requires file path" >&2; return 1; }

    # Find most recent backup
    local backup_file
    backup_file=$(find "$(dirname "$file")" -name "$(basename "$file").${backup_pattern}_*" -type f 2>/dev/null | sort -r | head -n1)

    if [[ -z "$backup_file" ]]; then
        echo "Error: no backup found for $file with pattern $backup_pattern" >&2
        return 1
    fi

    if cp "$backup_file" "$file" 2>/dev/null; then
        echo "Restored $file from $backup_file"
        return 0
    else
        echo "Error: failed to restore $file from $backup_file" >&2
        return 1
    fi
}

# Copy file with verification
file_copy_safe() {
    local source="${1}"
    local dest="${2}"

    [[ -z "$source" || -z "$dest" ]] && { echo "Error: file_copy_safe requires source and destination" >&2; return 1; }
    [[ ! -f "$source" ]] && { echo "Error: source file does not exist: $source" >&2; return 1; }

    # Create destination directory if needed
    local dest_dir
    dest_dir=$(dirname "$dest")
    [[ ! -d "$dest_dir" ]] && mkdir -p "$dest_dir"

    # Copy and verify
    if cp "$source" "$dest" 2>/dev/null; then
        # Verify file sizes match
        local source_size dest_size
        source_size=$(stat -f%z "$source" 2>/dev/null || stat -c%s "$source" 2>/dev/null)
        dest_size=$(stat -f%z "$dest" 2>/dev/null || stat -c%s "$dest" 2>/dev/null)

        if [[ "$source_size" == "$dest_size" ]]; then
            return 0
        else
            echo "Error: copy verification failed - size mismatch" >&2
            rm -f "$dest"
            return 1
        fi
    else
        echo "Error: failed to copy $source to $dest" >&2
        return 1
    fi
}

# Move file atomically (copy + verify + delete)
file_move_safe() {
    local source="${1}"
    local dest="${2}"

    [[ -z "$source" || -z "$dest" ]] && { echo "Error: file_move_safe requires source and destination" >&2; return 1; }
    [[ ! -f "$source" ]] && { echo "Error: source file does not exist: $source" >&2; return 1; }

    # First copy safely
    if file_copy_safe "$source" "$dest"; then
        # Only remove source if copy was successful
        if rm "$source" 2>/dev/null; then
            return 0
        else
            echo "Error: failed to remove source file after copy: $source" >&2
            return 1
        fi
    else
        return 1
    fi
}

# Change file permissions safely (with backup)
file_chmod_safe() {
    local file="${1}"
    local permissions="${2}"
    local create_backup="${3:-true}"

    [[ -z "$file" || -z "$permissions" ]] && { echo "Error: file_chmod_safe requires file and permissions" >&2; return 1; }
    [[ ! -f "$file" ]] && { echo "Error: file does not exist: $file" >&2; return 1; }

    # Create backup of current permissions if requested
    if [[ "$create_backup" == "true" ]]; then
        local current_perms
        current_perms=$(stat -f%Mp%Lp "$file" 2>/dev/null || stat -c%a "$file" 2>/dev/null)
        echo "$current_perms" > "${file}.perms_backup" 2>/dev/null
    fi

    # Apply new permissions
    if chmod "$permissions" "$file" 2>/dev/null; then
        return 0
    else
        echo "Error: failed to change permissions on $file" >&2
        return 1
    fi
}

# Create a temporary file with optional prefix and custom temp directory
file_temp() {
    local prefix="${1:-tmp}"
    local suffix="${2}"
    local temp_dir="${3:-${TEMP_DIR:-./.tmp}}"

    # Create temp directory if it doesn't exist
    [[ ! -d "$temp_dir" ]] && mkdir -p "$temp_dir"

    # Generate unique filename
    local random_id
    random_id=$(date +%s)$$
    local temp_file="${temp_dir}/${prefix}.${random_id}${suffix}"

    # Create the temp file
    if touch "$temp_file" 2>/dev/null; then
        echo "$temp_file"
        return 0
    else
        echo "Error: failed to create temporary file" >&2
        return 1
    fi
}

# Check if file is readable
file_readable() {
    local file="${1}"
    [[ -z "$file" ]] && { echo "Error: file_readable requires file path" >&2; return 1; }
    [[ -r "$file" ]]
}

# Check if file is writable
file_writable() {
    local file="${1}"
    [[ -z "$file" ]] && { echo "Error: file_writable requires file path" >&2; return 1; }
    [[ -w "$file" ]]
}

# Get file size in bytes
file_size() {
    local file="${1}"
    [[ -z "$file" ]] && { echo "Error: file_size requires file path" >&2; return 1; }
    [[ ! -f "$file" ]] && { echo "Error: file does not exist: $file" >&2; return 1; }

    # Cross-platform file size
    stat -f%z "$file" 2>/dev/null || stat -c%s "$file" 2>/dev/null
}

# Get file modification time (epoch)
file_mtime() {
    local file="${1}"
    [[ -z "$file" ]] && { echo "Error: file_mtime requires file path" >&2; return 1; }
    [[ ! -f "$file" ]] && { echo "Error: file does not exist: $file" >&2; return 1; }

    # Cross-platform modification time
    stat -f%m "$file" 2>/dev/null || stat -c%Y "$file" 2>/dev/null
}
