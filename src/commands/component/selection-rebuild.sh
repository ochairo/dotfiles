#!/usr/bin/env bash
# usage: dot selection-rebuild
# summary: Reconstruct last selection from ledger component column
# group: maintenance
set -euo pipefail
# All constants and paths are now provided by the dot script via environment variables
# shellcheck disable=SC1091
source "$CORE_DIR/init/bootstrap.sh"
core_require log selection

if [[ ! -f $LEDGER_FILE ]]; then
	log_error "No ledger file present"
	exit 1
fi
list=$(awk 'NR>1 && $4!="" {print $4}' "$LEDGER_FILE" | sort -u | tr '\n' ' ')
selection_save "$list"
log_info "Rebuilt selection: $list"
