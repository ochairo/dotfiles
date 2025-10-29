#!/usr/bin/env bash
# transactional/apply.sh - commit & rollback

tx_commit() {
    tx_is_enabled && [[ -n "$TX_JOURNAL" ]] || return 0
    local failed=0 line action timestamp details
    while IFS='|' read -r action timestamp details; do
        case "$action" in
            FILE)
                local dest target staged backup
                dest=$(echo "$details" | cut -d' ' -f1)
                target=$(echo "$details" | cut -d' ' -f2-)
                [[ -e "$dest" ]] && backup="${TX_DIR}/backup${dest}.$(date +%s)" && mkdir -p "$(dirname "$backup")" && mv "$dest" "$backup"
                staged="${TX_DIR}/stage${dest}"; [[ -f "$staged" ]] && mkdir -p "$(dirname "$dest")" && cp "$staged" "$dest" || ((failed++))
                ;;
            DIR)
                local dest target staged backup
                dest=$(echo "$details" | cut -d' ' -f1)
                target=$(echo "$details" | cut -d' ' -f2-)
                [[ -e "$dest" ]] && backup="${TX_DIR}/backup${dest}.$(date +%s)" && mkdir -p "$(dirname "$backup")" && mv "$dest" "$backup"
                staged="${TX_DIR}/stage${dest}"; [[ -d "$staged" ]] && mkdir -p "$(dirname "$dest")" && cp -r "$staged" "$dest" || ((failed++))
                ;;
            SYMLINK)
                local link target backup
                link=$(echo "$details" | cut -d' ' -f1)
                target=$(echo "$details" | cut -d' ' -f2-)
                [[ -e "$link" || -L "$link" ]] && backup="${TX_DIR}/backup${link}.$(date +%s)" && mkdir -p "$(dirname "$backup")" && mv "$link" "$backup"
                mkdir -p "$(dirname "$link")"; ln -sf "$target" "$link" || ((failed++))
                ;;
            DELETE)
                local path="$details"; [[ -e "$path" ]] && rm -rf "$path" ;;
        esac
    done < <(grep -v "^BEGIN\|^COMMIT\|^ROLLBACK" "$TX_JOURNAL")
    if [[ $failed -eq 0 ]]; then echo "COMMIT|$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$TX_JOURNAL"; return 0; fi
    return 1
}

tx_rollback() {
    tx_is_enabled && [[ -n "$TX_JOURNAL" ]] || return 0
    if [[ -d "${TX_DIR}/backup" ]]; then
        find "${TX_DIR}/backup" -type f -o -type l | while read -r backup; do
            local original="${backup#"${TX_DIR}"/backup}"
            [[ -n "$original" ]] && mkdir -p "$(dirname "$original")" && cp -a "$backup" "$original"
        done
    fi
    echo "ROLLBACK|$(date -u +%Y-%m-%dT%H:%M:%SZ)" >> "$TX_JOURNAL"
    return 0
}
