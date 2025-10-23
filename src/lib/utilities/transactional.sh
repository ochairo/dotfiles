#!/usr/bin/env bash
# transactional.sh - Transaction management for safe installations
# Reusable across any shell script project (macOS and Linux compatible)

# Prevent double loading
[[ -n "${INSTALL_TRANSACTIONAL_LOADED:-}" ]] && return 0
readonly INSTALL_TRANSACTIONAL_LOADED=1

# Transaction state
TX_ID=""
TX_DIR=""
TX_ENABLED=0
TX_JOURNAL=""

# Enable transactional mode
# Args: transaction_dir (optional, default: /tmp/transactions)
# Returns: 0 if success
# Example: tx_enable "/var/lib/transactions"
tx_enable() {
    local base_dir="${1:-/tmp/transactions}"
    TX_ENABLED=1
    export TX_ENABLED
    mkdir -p "$base_dir"
}

# Disable transactional mode
# Example: tx_disable
tx_disable() {
    TX_ENABLED=0
    export TX_ENABLED
}

# Check if transactional mode is enabled
# Returns: 0 if enabled, 1 otherwise
# Example: if tx_is_enabled; then echo "Transactional"; fi
tx_is_enabled() {
    [[ $TX_ENABLED -eq 1 ]]
}

# Begin a new transaction
# Args: transaction_name (optional)
# Returns: transaction ID
# Example: tx_id=$(tx_begin "install-packages")
tx_begin() {
    local name="${1:-transaction}"

    if ! tx_is_enabled; then
        return 0
    fi

    TX_ID="${name}-$(date +%s)-$$"
    TX_DIR="/tmp/transactions/${TX_ID}"
    TX_JOURNAL="${TX_DIR}/journal.log"

    mkdir -p "${TX_DIR}/stage"
    mkdir -p "${TX_DIR}/backup"

    echo "BEGIN|$(date -u +%Y-%m-%dT%H:%M:%SZ)|${TX_ID}" > "$TX_JOURNAL"

    export TX_ID TX_DIR TX_JOURNAL

    echo "$TX_ID"
}

# Record an action in the transaction journal
# Args: action_type, details...
# Example: tx_record "FILE_CREATE" "/tmp/file.txt"
tx_record() {
    if ! tx_is_enabled || [[ -z "$TX_JOURNAL" ]]; then
        return 0
    fi

    local action="${1}"
    shift
    local details="$*"
    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    echo "${action}|${timestamp}|${details}" >> "$TX_JOURNAL"
}

# Stage a file operation (copy to staging area)
# Args: source_file, destination_path
# Example: tx_stage_file "/tmp/app" "/usr/local/bin/app"
tx_stage_file() {
    local src="${1}"
    local dest="${2}"

    if ! tx_is_enabled; then
        # Direct operation if not transactional
        cp "$src" "$dest"
        return
    fi

    local staged="${TX_DIR}/stage${dest}"
    mkdir -p "$(dirname "$staged")"
    cp "$src" "$staged"

    tx_record "FILE" "$dest" "$src"
}

# Stage a directory operation
# Args: source_dir, destination_path
# Example: tx_stage_dir "/tmp/config" "/etc/myapp"
tx_stage_dir() {
    local src="${1}"
    local dest="${2}"

    if ! tx_is_enabled; then
        cp -r "$src" "$dest"
        return
    fi

    local staged="${TX_DIR}/stage${dest}"
    mkdir -p "$(dirname "$staged")"
    cp -r "$src" "$staged"

    tx_record "DIR" "$dest" "$src"
}

# Stage a symlink operation
# Args: target, link_path
# Example: tx_stage_symlink "/opt/app/bin" "/usr/local/bin/app"
tx_stage_symlink() {
    local target="${1}"
    local link="${2}"

    if ! tx_is_enabled; then
        ln -sf "$target" "$link"
        return
    fi

    local staged="${TX_DIR}/stage${link}"
    mkdir -p "$(dirname "$staged")"
    ln -sf "$target" "$staged"

    tx_record "SYMLINK" "$link" "$target"
}

# Stage a deletion operation
# Args: path
# Example: tx_stage_delete "/tmp/old-file"
tx_stage_delete() {
    local path="${1}"

    if ! tx_is_enabled; then
        rm -rf "$path"
        return
    fi

    # Backup before deletion
    if [[ -e "$path" ]]; then
        local backup="${TX_DIR}/backup${path}"
        mkdir -p "$(dirname "$backup")"
        cp -a "$path" "$backup"
        tx_record "DELETE" "$path"
    fi
}

# Commit the transaction (apply all staged operations)
# Returns: 0 if success, 1 if failure
# Example: tx_commit
tx_commit() {
    if ! tx_is_enabled || [[ -z "$TX_JOURNAL" ]]; then
        return 0
    fi

    local failed=0

    # Apply all operations from journal
    while IFS='|' read -r action timestamp details; do
        case "$action" in
            FILE)
                local dest target
                dest=$(echo "$details" | cut -d' ' -f1)
                target=$(echo "$details" | cut -d' ' -f2-)

                # Backup existing file
                if [[ -e "$dest" ]]; then
                    local backup
                    backup="${TX_DIR}/backup${dest}.$(date +%s)"
                    mkdir -p "$(dirname "$backup")"
                    mv "$dest" "$backup"
                fi

                # Copy from stage
                local staged="${TX_DIR}/stage${dest}"
                if [[ -f "$staged" ]]; then
                    mkdir -p "$(dirname "$dest")"
                    cp "$staged" "$dest" || ((failed++))
                fi
                ;;

            DIR)
                local dest target
                dest=$(echo "$details" | cut -d' ' -f1)
                target=$(echo "$details" | cut -d' ' -f2-)

                if [[ -e "$dest" ]]; then
                    local backup
                    backup="${TX_DIR}/backup${dest}.$(date +%s)"
                    mkdir -p "$(dirname "$backup")"
                    mv "$dest" "$backup"
                fi

                local staged="${TX_DIR}/stage${dest}"
                if [[ -d "$staged" ]]; then
                    mkdir -p "$(dirname "$dest")"
                    cp -r "$staged" "$dest" || ((failed++))
                fi
                ;;

            SYMLINK)
                local link target
                link=$(echo "$details" | cut -d' ' -f1)
                target=$(echo "$details" | cut -d' ' -f2-)

                if [[ -e "$link" || -L "$link" ]]; then
                    local backup
                    backup="${TX_DIR}/backup${link}.$(date +%s)"
                    mkdir -p "$(dirname "$backup")"
                    mv "$link" "$backup"
                fi

                mkdir -p "$(dirname "$link")"
                ln -sf "$target" "$link" || ((failed++))
                ;;

            DELETE)
                local path="$details"
                [[ -e "$path" ]] && rm -rf "$path"
                ;;
        esac
    done < <(grep -v "^BEGIN\|^COMMIT\|^ROLLBACK" "$TX_JOURNAL")

    if [[ $failed -eq 0 ]]; then
        echo "COMMIT|$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$TX_JOURNAL"
        return 0
    else
        return 1
    fi
}

# Rollback the transaction (restore from backups)
# Returns: 0 if success
# Example: tx_rollback
tx_rollback() {
    if ! tx_is_enabled || [[ -z "$TX_JOURNAL" ]]; then
        return 0
    fi

    # Restore from backups
    if [[ -d "${TX_DIR}/backup" ]]; then
        find "${TX_DIR}/backup" -type f -o -type l | while read -r backup; do
            local original="${backup#"${TX_DIR}"/backup}"
            if [[ -n "$original" ]]; then
                mkdir -p "$(dirname "$original")"
                cp -a "$backup" "$original"
            fi
        done
    fi

    echo "ROLLBACK|$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$TX_JOURNAL"

    return 0
}

# Clean up transaction directory
# Example: tx_cleanup
tx_cleanup() {
    if [[ -n "$TX_DIR" && -d "$TX_DIR" ]]; then
        rm -rf "$TX_DIR"
    fi

    TX_ID=""
    TX_DIR=""
    TX_JOURNAL=""
}

# Execute function within a transaction
# Args: function_name, args...
# Returns: function exit code
# Example: tx_execute install_packages "git" "vim"
tx_execute() {
    local func="${1}"
    shift

    if ! tx_is_enabled; then
        "$func" "$@"
        return $?
    fi

    tx_begin "$func"

    if "$func" "$@"; then
        tx_commit
        local result=$?
        tx_cleanup
        return $result
    else
        tx_rollback
        tx_cleanup
        return 1
    fi
}

# Get transaction status
# Returns: current transaction ID or "none"
# Example: status=$(tx_status)
tx_status() {
    if [[ -n "$TX_ID" ]]; then
        echo "$TX_ID"
    else
        echo "none"
    fi
}
