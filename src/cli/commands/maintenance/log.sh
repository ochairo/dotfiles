#!/usr/bin/env bash
# usage: dot compact-log [--dry-run]
# summary: Deduplicate ledger entries (--dry-run to preview changes)
# group: maintenance
set -euo pipefail

# All modules loaded by bin/dot

DRY=0
for a in "$@"; do
	case $a in
	--dry-run) DRY=1 ;;
	-h | --help)
		grep '^# usage:' "$0" | sed 's/# usage: //'
		exit 0
		;;
	*) log_warn "Unknown flag $a" ;;
	esac
done

[[ -f $LEDGER_FILE ]] || {
	log_warn "No ledger present"
	exit 0
}

tmp="${LEDGER_FILE}.compact.$$"
header=$(head -1 "$LEDGER_FILE")
echo "$header" >"$tmp"

# Build associative array mapping dest->line (preferring later lines)
declare -A latest
tail -n +2 "$LEDGER_FILE" | while IFS=$'\t' read -r dest src sum comp; do
	[[ -z $dest ]] && continue
	latest["$dest"]="$dest\t$src\t$sum\t$comp"
done

# Output in sorted order for determinism
for k in "${!latest[@]}"; do
	printf '%s
' "${latest[$k]}" >>"$tmp"
done

orig_lines=$(wc -l <"$LEDGER_FILE" | tr -d ' ')
new_lines=$(wc -l <"$tmp" | tr -d ' ')

if [[ $DRY == 1 ]]; then
	log_info "Dry-run: would reduce lines $orig_lines -> $new_lines"
	if command -v diff >/dev/null 2>&1; then diff -u "$LEDGER_FILE" "$tmp" || true; fi
	rm -f "$tmp"
	exit 0
fi

cp "$LEDGER_FILE" "$LEDGER_FILE.bak.$(date +%s)"
mv "$tmp" "$LEDGER_FILE"
log_info "Compacted ledger lines $orig_lines -> $new_lines"
