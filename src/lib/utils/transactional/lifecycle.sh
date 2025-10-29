#!/usr/bin/env bash
# transactional/lifecycle.sh - begin, record, cleanup

tx_begin() {
    local name="${1:-transaction}"
    tx_is_enabled || return 0
    TX_ID="${name}-$(date +%s)-$$"
    TX_DIR="/tmp/transactions/${TX_ID}"
    TX_JOURNAL="${TX_DIR}/journal.log"
    mkdir -p "${TX_DIR}/stage" "${TX_DIR}/backup"
    echo "BEGIN|$(date -u +%Y-%m-%dT%H:%M:%SZ)|${TX_ID}" > "$TX_JOURNAL"
    export TX_ID TX_DIR TX_JOURNAL
    echo "$TX_ID"
}

tx_record() {
    tx_is_enabled && [[ -n "$TX_JOURNAL" ]] || return 0
    local action="$1"; shift; local details="$*" timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    echo "${action}|${timestamp}|${details}" >> "$TX_JOURNAL"
}

tx_cleanup() { [[ -n "$TX_DIR" && -d "$TX_DIR" ]] && rm -rf "$TX_DIR"; TX_ID=""; TX_DIR=""; TX_JOURNAL=""; }
