#!/usr/bin/env bash
# core/selection.sh - selection persistence & reconstruction (stub)

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/constants.sh"

selection_save() {
	local list="$*"
	echo "$list" >"$LAST_SELECTION_FILE"
}

selection_load() {
	[[ -f $LAST_SELECTION_FILE ]] && cat "$LAST_SELECTION_FILE" || true
}

selection_reconstruct() {
	# TODO: parse ledger and map to components using metadata
	awk 'NR>1 && $1 !~ /^#/ {print $4}' "$LEDGER_FILE" | sort -u | tr '\n' ' '
}
