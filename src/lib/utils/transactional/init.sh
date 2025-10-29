#!/usr/bin/env bash
# transactional/init.sh - Guard, state, enable/disable/status
[[ -n "${INSTALL_TRANSACTIONAL_LOADED:-}" ]] && return 0
readonly INSTALL_TRANSACTIONAL_LOADED=1
TX_ID="" TX_DIR="" TX_ENABLED=0 TX_JOURNAL=""

tx_enable() { local base_dir="${1:-/tmp/transactions}"; TX_ENABLED=1; export TX_ENABLED; mkdir -p "$base_dir"; }
tx_disable() { TX_ENABLED=0; export TX_ENABLED; }
tx_is_enabled() { [[ $TX_ENABLED -eq 1 ]]; }
tx_status() { [[ -n "$TX_ID" ]] && echo "$TX_ID" || echo "none"; }
