#!/usr/bin/env bash
# usage: dot ledger migrate [--dry-run]
# summary: Migrate symlink ledger to latest format (--dry-run to preview)
# group: maintenance
set -euo pipefail

# All constants and paths are now provided by the dot script via environment variables
# shellcheck disable=SC1091
source "$CORE_DIR/bootstrap.sh"
core_require log fs
LEDGER_FILE="${LEDGER_FILE:-$LEDGER_FILE}" # from constants via fs

cmd=${1:-}
case "$cmd" in
migrate)
	shift || true
	DRY=0
	for a in "$@"; do [[ $a == --dry-run ]] && DRY=1; done
	if [[ ! -f $LEDGER_FILE ]]; then
		log_warn "No ledger file present ($LEDGER_FILE)"
		exit 0
	fi
	if grep -q '^# ledgerv1' "$LEDGER_FILE"; then
		log_info "Ledger already v1"
		exit 0
	fi
	tmp="$LEDGER_FILE.migrate.$$"
	log_info "Migrating ledger to v1 format"
	{
		echo "# ledgerv1 fields=dest,src,component migrated=$(date -u +%FT%TZ)"
		awk 'NF>=2 {dest=$1;src=$2; print dest"\t"src"\t""}' "$LEDGER_FILE"
	} >"$tmp"
	if [[ $DRY == 1 ]]; then
		log_info "Dry-run: showing diff"
		if command -v diff >/dev/null 2>&1; then diff -u "$LEDGER_FILE" "$tmp" || true; fi
		rm -f "$tmp"
		exit 0
	fi
	cp "$LEDGER_FILE" "$LEDGER_FILE.bak.$(date +%s)"
	mv "$tmp" "$LEDGER_FILE"
	log_info "Ledger migrated to v1"
	;;
*)
	echo "Usage: dot ledger migrate [--dry-run]" >&2
	exit 1
	;;
esac
