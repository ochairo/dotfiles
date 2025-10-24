#!/usr/bin/env bash
# usage: dot status [--json] [--quiet]
# summary: Show symlink status (--json, --quiet options)
# group: core

# Ensure we're using bash 4+ for associative arrays
if [[ ${BASH_VERSION%%.*} -lt 4 ]]; then
    msg_error "This script requires bash 4.0 or later for associative arrays"
    msg_error "Current bash version: $BASH_VERSION"
    exit 1
fi

set -euo pipefail

# All modules loaded by bin/dot

JSON=0 QUIET=0
for a in "$@"; do
	case $a in
	--json) JSON=1 ;;
	--quiet) QUIET=1 ;;
	esac
done

# Initialize counters
declare -A counts=([OK]=0 [MISSING]=0 [BROKEN]=0 [NOTSYMLINK]=0)
rows=()

# Read ledger and check symlink status
if [[ -f "$LEDGER_FILE" ]]; then
	while IFS=$'\t' read -r dest src _comp; do
		[[ -z "$dest" || "$dest" == \#* ]] && continue

		status=""
		if [[ -L "$dest" ]]; then
			if [[ "$(readlink "$dest")" == "$src" ]]; then
				if [[ -e "$dest" ]]; then
					status="OK"
				else
					status="BROKEN"
				fi
			else
				status="BROKEN"
			fi
		elif [[ -e "$dest" ]]; then
			status="NOTSYMLINK"
		else
			status="MISSING"
		fi

		counts[$status]=$((counts[$status] + 1))
		rows+=("$status\t$dest\t$src")
	done <"$LEDGER_FILE"
fi

if [[ $JSON == 1 ]]; then
	printf '{"summary":{'
	first=1
	for k in "${!counts[@]}"; do
		[[ $first == 1 ]] || printf ','
		first=0
		printf '"%s":%s' "$k" "${counts[$k]}"
	done
	printf '},"entries":['
	for i in "${!rows[@]}"; do
		IFS=$'\t' read -r st d s <<<"${rows[$i]}"
		printf '%s{"status":"%s","dest":%s,"src":%s}' \
			"$([[ $i -gt 0 ]] && echo ',')" \
			"$st" \
			"$(printf '%s' "$d" | jq -R '.')" \
			"$(printf '%s' "$s" | jq -R '.')"
	done
	printf ']}'
	echo
	exit 0
fi

if [[ $QUIET == 0 ]]; then
	for r in "${rows[@]}"; do
		IFS=$'\t' read -r st d s <<<"$r"
		printf '%-10s %s -> %s\n' "$st" "$d" "$s"
	done
fi

printf '\nSummary: '
for k in OK MISSING BROKEN NOTSYMLINK; do printf '%s=%s ' "$k" "${counts[$k]}"; done
echo
