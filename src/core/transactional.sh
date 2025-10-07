#!/usr/bin/env bash
# core/transactional.sh - transactional staging (scaffold)
set -euo pipefail

source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/constants.sh"
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/log.sh"

transaction_begin() {
	[[ ${DOTFILES_TRANSACTIONAL:-0} == 1 ]] || return 0
	uuid=$(date +%s)-$RANDOM
	export DOT_TXN_DIR="$STATE_DIR/transactions/$uuid"
	mkdir -p "$DOT_TXN_DIR/stage" || return 1
	echo "begin $uuid $(date -u +%FT%TZ)" >"$DOT_TXN_DIR/journal.log"
	log_debug "Transaction started $uuid"
}

transaction_stage_symlink() {
	[[ ${DOTFILES_TRANSACTIONAL:-0} == 1 ]] || {
		fs_symlink "$1" "$2" "$3"
		return
	}
	local src=$1 dest=$2 comp=${3:-}
	local staged_dest="$DOT_TXN_DIR/stage$dest"
	mkdir -p "$(dirname "$staged_dest")"
	# Remove existing staged symlink if it exists
	rm -f "$staged_dest"
	ln -s "$src" "$staged_dest"
	echo -e "link\t$dest\t$src\t$comp" >>"$DOT_TXN_DIR/journal.log"
}

transaction_commit() {
	[[ ${DOTFILES_TRANSACTIONAL:-0} == 1 ]] || return 0
	log_debug "Committing transaction at $DOT_TXN_DIR"
	awk -F '\t' '/^link/ {print $2"\t"$3"\t"$4}' "$DOT_TXN_DIR/journal.log" | while IFS=$'\t' read -r dest src comp; do
		# Directly create symlinks without going through transactional fs_symlink
		if [[ -L $dest && $(readlink "$dest") == "$src" ]]; then
			log_info "Symlink OK: $dest"
		else
			# Remove or backup existing destination
			if [[ -e $dest || -L $dest ]]; then
				if [[ ${DOTFILES_BACKUP:-0} == 1 ]]; then
					local backup
					backup="${dest}.backup.$(date +%s)"
					mv "$dest" "$backup"
					log_info "Backed up $dest to $backup"
				else
					rm -rf "$dest"
				fi
			fi
			mkdir -p "$(dirname "$dest")"
			ln -s "$src" "$dest"
			# Record the symlink in ledger
			if [[ -n ${LEDGER_FILE:-} ]]; then
				mkdir -p "$(dirname "$LEDGER_FILE")"
				printf '%s\t%s\t%s\n' "$dest" "$src" "$comp" >>"$LEDGER_FILE"
			fi
			log_info "Linked $dest -> $src"
		fi
	done
	echo "commit $(date -u +%FT%TZ)" >>"$DOT_TXN_DIR/journal.log"
}

transaction_rollback() {
	[[ ${DOTFILES_TRANSACTIONAL:-0} == 1 ]] || return 0
	echo "rollback $(date -u +%FT%TZ)" >>"$DOT_TXN_DIR/journal.log"
	log_warn "Rolled back transaction"
}
