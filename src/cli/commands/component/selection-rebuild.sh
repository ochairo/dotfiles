#!/usr/bin/env bash
# usage: dot selection-rebuild
# summary: Reconstruct last selection from ledger component column
# group: maintenance
set -euo pipefail

# All modules loaded by bin/dot

if [[ ! -f $LEDGER_FILE ]]; then
  if declare -F msg_error >/dev/null 2>&1; then msg_error "No ledger file present"; else echo "[ERROR] No ledger file present" >&2; fi
  exit 1
fi
list=$(awk 'NR>1 && $4!="" {print $4}' "$LEDGER_FILE" | sort -u | tr '\n' ' ')
selection_save "$list"
if declare -F msg_success >/dev/null 2>&1; then msg_success "Rebuilt selection: $list"; else echo "[INFO] Rebuilt selection: $list" >&2; fi
