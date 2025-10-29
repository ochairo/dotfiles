#!/usr/bin/env bash
# symlinks.sh - Generic symlink utilities
# Basic symlink operations (not dotfiles-specific)

# Prevent double loading
[[ -n "${SYMLINK_UTILS_LOADED:-}" ]] && return 0
readonly SYMLINK_UTILS_LOADED=1

# Create symlink with backup of existing file
# Args: source, destination, backup_suffix (default: .backup)
# Returns: 0 if success, 1 otherwise
# Example: symlink_create "/opt/app/bin" "/usr/local/bin/app"
symlink_create() {
    local src="${1}"
    local dest="${2}"
    local backup_suffix="${3:-.backup}"

    if [[ ! -e "$src" ]]; then
        return 1
    fi

    # Backup existing file/link
    if [[ -e "$dest" || -L "$dest" ]]; then
        mv "$dest" "${dest}${backup_suffix}"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$dest")"

    ln -sf "$src" "$dest"
}

# Remove symlink
# Args: symlink_path
# Returns: 0 if success, 1 otherwise
# Example: symlink_remove "/usr/local/bin/app"
symlink_remove() {
    local link="${1}"

    if [[ -L "$link" ]]; then
        rm "$link"
        return 0
    fi

    return 1
}

# Check if path is a symlink
# Args: path
# Returns: 0 if symlink, 1 otherwise
# Example: if symlink_is "$file"; then echo "Is symlink"; fi
symlink_is() {
    [[ -L "${1}" ]]
}

# Get symlink target
# Args: symlink_path
# Returns: target path
# Example: target=$(symlink_target "/usr/local/bin/app")
symlink_target() {
    local link="${1}"

    if [[ ! -L "$link" ]]; then
        return 1
    fi

    readlink "$link"
}

# Verify symlink points to expected target
# Args: symlink_path, expected_target
# Returns: 0 if matches, 1 otherwise
# Example: if symlink_verify "/usr/local/bin/app" "/opt/app/bin"; then echo "OK"; fi
symlink_verify() {
    local link="${1}"
    local expected="${2}"

    if [[ ! -L "$link" ]]; then
        return 1
    fi

    local actual
    actual=$(readlink "$link")

    [[ "$actual" == "$expected" ]]
}

# Create symlink forcefully (remove existing first)
# Args: source, destination
# Returns: 0 if success, 1 otherwise
# Example: symlink_force "/opt/app/bin" "/usr/local/bin/app"
symlink_force() {
    local src="${1}"
    local dest="${2}"

    if [[ ! -e "$src" ]]; then
        return 1
    fi

    # Remove existing file/link without backup
    if [[ -e "$dest" || -L "$dest" ]]; then
        rm -rf "$dest"
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$dest")"

    ln -sf "$src" "$dest"
}

# Check if symlink is broken
# Args: symlink_path
# Returns: 0 if broken, 1 if valid or not a symlink
# Example: if symlink_is_broken "$link"; then echo "Broken"; fi
symlink_is_broken() {
    local link="${1}"

    # Check if it's a symlink
    if [[ ! -L "$link" ]]; then
        return 1
    fi

    # Check if target exists
    if [[ ! -e "$link" ]]; then
        return 0  # Broken
    fi

    return 1  # Valid
}

# Batch create symlinks from directory
# Args: source_dir, target_dir, pattern (default: *)
# Returns: 0 if success
# Example: symlink_batch "/opt/app/bin" "/usr/local/bin" "*.sh"
symlink_batch() {
    local src_dir="${1}"
    local dest_dir="${2}"
    local pattern="${3:-*}"

    if [[ ! -d "$src_dir" ]]; then
        return 1
    fi

    mkdir -p "$dest_dir"

    find "$src_dir" -maxdepth 1 -name "$pattern" -type f | while read -r file; do
        local basename
        basename=$(basename "$file")
        symlink_create "$file" "$dest_dir/$basename"
    done
}
