#!/usr/bin/env bash
# usage: dot ledger migrate [--dry-run]
# summary: Migrate symlink ledger to latest format (--dry-run to preview)
# group: maintenance
set -euo pipefail

# All modules loaded by bin/dot

cmd=${1:-}
case "$cmd" in
migrate)
	shift || true
	DRY=0
	for a in "$@"; do [[ $a == --dry-run ]] && DRY=1; done
	if [[ ! -f $LEDGER_FILE ]]; then
		if declare -F msg_warn >/dev/null 2>&1; then msg_warn "No ledger file present ($LEDGER_FILE)"; else echo "[WARN] No ledger file present ($LEDGER_FILE)" >&2; fi
		exit 0
	fi
	if grep -q '^# ledgerv1' "$LEDGER_FILE"; then
		if declare -F msg_info >/dev/null 2>&1; then msg_info "Ledger already v1"; else echo "[INFO] Ledger already v1" >&2; fi
		exit 0
	fi
	tmp="$LEDGER_FILE.migrate.$$"
	if declare -F msg_info >/dev/null 2>&1; then msg_info "Migrating ledger to v1 format"; else echo "[INFO] Migrating ledger to v1 format" >&2; fi
	{
		echo "# ledgerv1 fields=dest,src,component migrated=$(date -u +%FT%TZ)"
		awk 'NF>=2 {dest=$1;src=$2; print dest"\t"src"\t""}' "$LEDGER_FILE"
	} >"$tmp"
	if [[ $DRY == 1 ]]; then
		if declare -F msg_info >/dev/null 2>&1; then msg_info "Dry-run: showing diff"; else echo "[INFO] Dry-run: showing diff" >&2; fi
		if command -v diff >/dev/null 2>&1; then diff -u "$LEDGER_FILE" "$tmp" || true; fi
		rm -f "$tmp"
		exit 0
	fi
	cp "$LEDGER_FILE" "$LEDGER_FILE.bak.$(date +%s)"
	mv "$tmp" "$LEDGER_FILE"
	if declare -F msg_success >/dev/null 2>&1; then msg_success "Ledger migrated to v1"; else echo "[INFO] Ledger migrated to v1" >&2; fi
	;;
*)
	msg_error "Usage: dot ledger migrate [--dry-run]"
	exit 1
	;;
esac
