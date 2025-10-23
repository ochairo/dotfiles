#!/usr/bin/env bash
# ledger.sh - Installation tracking ledger for dotfiles
# Records what has been installed and where

# Prevent double loading
[[ -n "${DOTFILES_LEDGER_LOADED:-}" ]] && return 0
readonly DOTFILES_LEDGER_LOADED=1

# Ledger file location
: "${DOTFILES_LEDGER:=$HOME/.dotfiles.ledger}"

# Ledger entry format: TYPE|COMPONENT|TARGET|SOURCE|TIMESTAMP
# Types: symlink, file, directory, backup, install

# Initialize ledger file if it doesn't exist
# Example: ledger_init
ledger_init() {
    if [[ ! -f "$DOTFILES_LEDGER" ]]; then
        touch "$DOTFILES_LEDGER"
    fi
}

# Add entry to ledger
# Args: type, component, target, [source]
# Example: ledger_add "symlink" "git" "$HOME/.gitconfig" "$DOTFILES_ROOT/configs/.gitconfig"
ledger_add() {
    local type="${1}"
    local component="${2}"
    local target="${3}"
    local source="${4:-}"
    local timestamp

    ledger_init

    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || date -u +"%Y-%m-%d %H:%M:%S")

    echo "${type}|${component}|${target}|${source}|${timestamp}" >> "$DOTFILES_LEDGER"
}

# Check if target is tracked in ledger
# Args: target_path
# Returns: 0 if tracked, 1 otherwise
# Example: if ledger_has "$HOME/.gitconfig"; then echo "Tracked"; fi
ledger_has() {
    local target="${1}"

    [[ ! -f "$DOTFILES_LEDGER" ]] && return 1

    grep -qF "|${target}|" "$DOTFILES_LEDGER"
}

# Get component that owns a target
# Args: target_path
# Returns: component name
# Example: owner=$(ledger_owner "$HOME/.gitconfig")
ledger_owner() {
    local target="${1}"

    [[ ! -f "$DOTFILES_LEDGER" ]] && return 1

    grep -F "|${target}|" "$DOTFILES_LEDGER" | tail -n 1 | cut -d'|' -f2
}

# Get all entries for a component
# Args: component_name
# Returns: ledger entries (one per line)
# Example: ledger_entries "git"
ledger_entries() {
    local component="${1}"

    [[ ! -f "$DOTFILES_LEDGER" ]] && return 0

    grep "^[^|]*|${component}|" "$DOTFILES_LEDGER"
}

# Get all targets for a component
# Args: component_name
# Returns: target paths (one per line)
# Example: ledger_targets "git"
ledger_targets() {
    local component="${1}"

    ledger_entries "$component" | cut -d'|' -f3
}

# Get all symlinks for a component
# Args: component_name
# Returns: target paths (one per line)
# Example: ledger_symlinks "git"
ledger_symlinks() {
    local component="${1}"

    [[ ! -f "$DOTFILES_LEDGER" ]] && return 0

    grep "^symlink|${component}|" "$DOTFILES_LEDGER" | cut -d'|' -f3
}

# Remove entries for a component
# Args: component_name
# Example: ledger_remove "git"
ledger_remove() {
    local component="${1}"
    local temp

    [[ ! -f "$DOTFILES_LEDGER" ]] && return 0

    temp=$(mktemp)
    grep -v "^[^|]*|${component}|" "$DOTFILES_LEDGER" > "$temp" || true
    mv "$temp" "$DOTFILES_LEDGER"
}

# Remove specific entry
# Args: target_path
# Example: ledger_remove_entry "$HOME/.gitconfig"
ledger_remove_entry() {
    local target="${1}"
    local temp

    [[ ! -f "$DOTFILES_LEDGER" ]] && return 0

    temp=$(mktemp)
    grep -vF "|${target}|" "$DOTFILES_LEDGER" > "$temp" || true
    mv "$temp" "$DOTFILES_LEDGER"
}

# List all components in ledger
# Returns: unique component names (one per line)
# Example: ledger_components
ledger_components() {
    [[ ! -f "$DOTFILES_LEDGER" ]] && return 0

    cut -d'|' -f2 "$DOTFILES_LEDGER" | sort -u
}

# Count entries in ledger
# Args: [component_name]
# Returns: number of entries
# Example: total=$(ledger_count) ; git_entries=$(ledger_count "git")
ledger_count() {
    local component="${1:-}"

    [[ ! -f "$DOTFILES_LEDGER" ]] && echo "0" && return 0

    if [[ -n "$component" ]]; then
        ledger_entries "$component" | wc -l | tr -d ' '
    else
        wc -l < "$DOTFILES_LEDGER" | tr -d ' '
    fi
}

# Get entry type
# Args: target_path
# Returns: entry type (symlink, file, directory, backup, install)
# Example: type=$(ledger_type "$HOME/.gitconfig")
ledger_type() {
    local target="${1}"

    [[ ! -f "$DOTFILES_LEDGER" ]] && return 1

    grep -F "|${target}|" "$DOTFILES_LEDGER" | tail -n 1 | cut -d'|' -f1
}

# Get entry source
# Args: target_path
# Returns: source path
# Example: src=$(ledger_source "$HOME/.gitconfig")
ledger_source() {
    local target="${1}"

    [[ ! -f "$DOTFILES_LEDGER" ]] && return 1

    grep -F "|${target}|" "$DOTFILES_LEDGER" | tail -n 1 | cut -d'|' -f4
}

# Get entry timestamp
# Args: target_path
# Returns: ISO 8601 timestamp
# Example: time=$(ledger_timestamp "$HOME/.gitconfig")
ledger_timestamp() {
    local target="${1}"

    [[ ! -f "$DOTFILES_LEDGER" ]] && return 1

    grep -F "|${target}|" "$DOTFILES_LEDGER" | tail -n 1 | cut -d'|' -f5
}

# Compact ledger (remove duplicates, keep latest)
# Example: ledger_compact
ledger_compact() {
    local temp

    [[ ! -f "$DOTFILES_LEDGER" ]] && return 0

    temp=$(mktemp)

    # Keep only latest entry for each target
    awk -F'|' '
        {
            key = $2 "|" $3  # component|target
            entries[key] = $0
        }
        END {
            for (key in entries) {
                print entries[key]
            }
        }
    ' "$DOTFILES_LEDGER" | sort > "$temp"

    mv "$temp" "$DOTFILES_LEDGER"
}

# Export ledger as JSON
# Returns: JSON array of entries
# Example: ledger_export_json > ledger.json
ledger_export_json() {
    [[ ! -f "$DOTFILES_LEDGER" ]] && echo "[]" && return 0

    echo "["
    local first=1
    while IFS='|' read -r type component target source timestamp; do
        if [[ $first -eq 1 ]]; then
            first=0
        else
            echo ","
        fi
        printf '  {"type":"%s","component":"%s","target":"%s","source":"%s","timestamp":"%s"}' \
            "$type" "$component" "$target" "$source" "$timestamp"
    done < "$DOTFILES_LEDGER"
    echo ""
    echo "]"
}

# Backup ledger
# Example: ledger_backup
ledger_backup() {
    [[ ! -f "$DOTFILES_LEDGER" ]] && return 0

    local backup
    backup="${DOTFILES_LEDGER}.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$DOTFILES_LEDGER" "$backup"
    echo "$backup"
}

# Verify ledger entries (check if targets still exist)
# Returns: list of missing targets
# Example: ledger_verify
ledger_verify() {
    [[ ! -f "$DOTFILES_LEDGER" ]] && return 0

    while IFS='|' read -r type component target source timestamp; do
        if [[ ! -e "$target" ]]; then
            echo "$target (from $component)"
        fi
    done < "$DOTFILES_LEDGER"
}
