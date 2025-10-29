#!/usr/bin/env bash
# transactional/execute.sh - execute wrapper

tx_execute() {
    local func="$1"; shift
    tx_is_enabled || { "$func" "$@"; return $?; }
    tx_begin "$func"
    if "$func" "$@"; then
        tx_commit; local result=$?; tx_cleanup; return $result
    else
        tx_rollback; tx_cleanup; return 1
    fi
}
