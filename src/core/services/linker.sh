#!/usr/bin/env bash
# symlinks.sh - Dotfiles-specific symlink management
# Handles creating, tracking, and removing symlinks with backup support

# Prevent double loading
[[ -n "${DOTFILES_SYMLINKS_LOADED:-}" ]] && return 0
readonly DOTFILES_SYMLINKS_LOADED=1

# Backup directory
: "${DOTFILES_BACKUP_DIR:=$HOME/.dotfiles.backup}"

# Create backup of existing file/directory
# Args: path
# Returns: backup path
# Example: backup=$(symlinks_backup "$HOME/.gitconfig")
symlinks_backup() {
    local path="${1}"
    local backup_dir="$DOTFILES_BACKUP_DIR"
    local timestamp
    local backup_path

    [[ ! -e "$path" ]] && return 0

    timestamp=$(date +%Y%m%d_%H%M%S)
    mkdir -p "$backup_dir"

    # Get relative path from home
    local rel_path="${path#"$HOME"/}"
    backup_path="$backup_dir/${rel_path}.${timestamp}"

    # Create parent directory in backup
    mkdir -p "$(dirname "$backup_path")"

    # Copy or move the file
    if [[ -L "$path" ]]; then
        # If it's a symlink, just record where it pointed
        readlink "$path" > "${backup_path}.symlink_target"
        rm "$path"
    elif [[ -d "$path" ]]; then
        mv "$path" "$backup_path"
    else
        mv "$path" "$backup_path"
    fi

    echo "$backup_path"
}

# Create symlink with backup and ledger tracking
# Args: source, target, component_name
# Returns: 0 on success, 1 on failure
# Example: symlinks_create "$DOTFILES_ROOT/configs/.gitconfig" "$HOME/.gitconfig" "git"
symlinks_create() {
    local source="${1}"
    local target="${2}"
    local component="${3}"
    local backup

    # Validate source exists
    if [[ ! -e "$source" ]]; then
        return 1
    fi

    # Check if target already exists and isn't our symlink
    if [[ -e "$target" || -L "$target" ]]; then
        if [[ -L "$target" ]]; then
            local current_target
            current_target=$(readlink "$target")
            if [[ "$current_target" == "$source" ]]; then
                # Already correctly linked
                return 0
            fi
        fi

        # Backup existing file
        backup=$(symlinks_backup "$target")
        if [[ -n "$backup" ]]; then
            # Record backup in ledger
            if command -v ledger_add >/dev/null 2>&1; then
                ledger_add "backup" "$component" "$backup" "$target"
            fi
        fi
    fi

    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"

    # Create the symlink
    if ln -sf "$source" "$target"; then
        # Record in ledger
        if command -v ledger_add >/dev/null 2>&1; then
            ledger_add "symlink" "$component" "$target" "$source"
        fi
        return 0
    else
        return 1
    fi
}

# Remove symlink and restore backup if available
# Args: target, component_name
# Returns: 0 on success, 1 on failure
# Example: symlinks_remove "$HOME/.gitconfig" "git"
symlinks_remove() {
    local target="${1}"
    local component="${2}"

    # Check if it's our symlink
    if [[ ! -L "$target" ]]; then
        return 1
    fi

    # Remove the symlink
    rm "$target"

    # Try to restore backup
    if command -v ledger_entries >/dev/null 2>&1; then
        local backup
        backup=$(ledger_entries "$component" | grep "^backup|" | grep "|${target}$" | tail -n 1 | cut -d'|' -f3)

        if [[ -n "$backup" && -e "$backup" ]]; then
            if [[ -f "${backup}.symlink_target" ]]; then
                # Was a symlink, recreate it
                local orig_target
                orig_target=$(cat "${backup}.symlink_target")
                ln -sf "$orig_target" "$target"
                rm "${backup}.symlink_target"
            else
                # Was a file/directory, restore it
                mv "$backup" "$target"
            fi
        fi
    fi

    # Remove from ledger
    if command -v ledger_remove_entry >/dev/null 2>&1; then
        ledger_remove_entry "$target"
    fi

    return 0
}

# Verify symlink is correct
# Args: target, expected_source
# Returns: 0 if correct, 1 otherwise
# Example: if symlinks_verify "$HOME/.gitconfig" "$DOTFILES_ROOT/configs/.gitconfig"; then echo "OK"; fi
symlinks_verify() {
    local target="${1}"
    local expected_source="${2}"

    [[ ! -L "$target" ]] && return 1

    local actual_source
    actual_source=$(readlink "$target")

    [[ "$actual_source" == "$expected_source" ]]
}

# List all symlinks for a component
# Args: component_name
# Returns: symlink paths (one per line)
# Example: symlinks_list "git"
symlinks_list() {
    local component="${1}"

    if command -v ledger_symlinks >/dev/null 2>&1; then
        ledger_symlinks "$component"
    fi
}

# Check if path is a dotfiles-managed symlink
# Args: path
# Returns: 0 if managed, 1 otherwise
# Example: if symlinks_is_managed "$HOME/.gitconfig"; then echo "Managed"; fi
symlinks_is_managed() {
    local path="${1}"

    if command -v ledger_has >/dev/null 2>&1; then
        ledger_has "$path"
    else
        return 1
    fi
}

# Get symlink target (what it points to)
# Args: symlink_path
# Returns: target path
# Example: target=$(symlinks_target "$HOME/.gitconfig")
symlinks_target() {
    local path="${1}"

    [[ ! -L "$path" ]] && return 1

    readlink "$path"
}

# Batch create symlinks from directory
# Args: source_dir, target_dir, component_name, [pattern]
# Returns: 0 on success
# Example: symlinks_batch_create "$DOTFILES_ROOT/configs/git" "$HOME" "git" ".*"
symlinks_batch_create() {
    local source_dir="${1}"
    local target_dir="${2}"
    local component="${3}"
    local pattern="${4:-.gitconfig}"

    [[ ! -d "$source_dir" ]] && return 1

    find "$source_dir" -maxdepth 1 -name "$pattern" -type f | while read -r file; do
        local basename
        basename=$(basename "$file")
        symlinks_create "$file" "$target_dir/$basename" "$component"
    done
}

# Remove all symlinks for a component
# Args: component_name
# Returns: number of symlinks removed
# Example: removed=$(symlinks_remove_all "git")
symlinks_remove_all() {
    local component="${1}"
    local count=0

    symlinks_list "$component" | while read -r target; do
        if symlinks_remove "$target" "$component"; then
            count=$((count + 1))
        fi
    done

    echo "$count"
}

# Verify all symlinks for a component
# Args: component_name
# Returns: list of broken symlinks
# Example: symlinks_verify_all "git"
symlinks_verify_all() {
    local component="${1}"

    if command -v ledger_symlinks >/dev/null 2>&1; then
        ledger_symlinks "$component" | while read -r target; do
            if [[ ! -L "$target" ]]; then
                echo "$target (missing)"
            elif [[ ! -e "$target" ]]; then
                echo "$target (broken)"
            fi
        done
    fi
}

# Repair broken symlinks
# Args: component_name
# Returns: number of symlinks repaired
# Example: repaired=$(symlinks_repair "git")
symlinks_repair() {
    local component="${1}"
    local count=0

    if command -v ledger_entries >/dev/null 2>&1; then
        ledger_entries "$component" | grep "^symlink|" | while IFS='|' read -r _ _ target source _; do
            if [[ ! -e "$target" ]] && [[ -e "$source" ]]; then
                if symlinks_create "$source" "$target" "$component"; then
                    count=$((count + 1))
                fi
            fi
        done
    fi

    echo "$count"
}
