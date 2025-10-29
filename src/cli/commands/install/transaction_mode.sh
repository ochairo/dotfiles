#!/usr/bin/env bash
# Transactional mode logic for install

function install_transaction_mode() {
  local fail=$1
  if [[ ${DOTFILES_TRANSACTIONAL:-0} == 1 ]]; then
    if [[ $fail == 1 ]]; then
  if declare -F msg_warn >/dev/null 2>&1; then msg_warn "Aborting transaction due to failure"; else echo "[WARN] Aborting transaction due to failure" >&2; fi
      install_transaction_rollback
    else
      install_transaction_commit
    fi
  fi
}

export -f install_transaction_mode
