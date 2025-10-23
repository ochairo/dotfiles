#!/usr/bin/env bash
# usage: dot selection-rebuild
# summary: Reconstruct last selection from ledger component column
# group: maintenance
set -euo pipefail

# All modules loaded by bin/dot

if [[ ! -f $LEDGER_FILE ]]; then
	log_error "No ledger file present"
	exit 1
fi
list=$(awk 'NR>1 && $4!="" {print $4}' "$LEDGER_FILE" | sort -u | tr '\n' ' ')
selection_save "$list"
log_info "Rebuilt selection: $list"
