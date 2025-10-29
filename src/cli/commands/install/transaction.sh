#!/usr/bin/env bash
# Transactional mode logic for install

function install_transaction_begin() {
  transaction_begin || {
    if declare -F msg_error >/dev/null 2>&1; then msg_error "Failed to begin transaction"; else echo "[ERROR] Failed to begin transaction" >&2; fi
    exit 1
  }
}

function install_transaction_commit() {
  transaction_commit || {
    if declare -F msg_error >/dev/null 2>&1; then msg_error "Transaction commit failed"; else echo "[ERROR] Transaction commit failed" >&2; fi
    exit 1
  }
}

function install_transaction_rollback() {
  transaction_rollback || true
}

export -f install_transaction_begin install_transaction_commit install_transaction_rollback
