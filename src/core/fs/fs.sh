#!/usr/bin/env bash
# core/fs.sh - filesystem helpers (migration from utils/fs.sh)

set -euo pipefail

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/init/constants.sh"
# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/io/log.sh"
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/fs/transactional.sh"

fs_backup_if_exists() {
	local target=$1
	if [[ -e $target || -L $target ]]; then
		local backup="${target}.bak.$(date +%s)"
		mv "$target" "$backup"
		log_warn "Backup created: $backup"
	fi
}

fs_remove_or_backup() {
	local target=$1
	if [[ -e $target || -L $target ]]; then
		if [[ ${DOTFILES_BACKUP:-0} == 1 ]]; then
			fs_backup_if_exists "$target"
		else
			rm -rf "$target"
			log_warn "Removed $target"
		fi
	fi
}

fs_symlink_record() {
	# dest src component(optional)
	local dest=$1 src=$2 comp=${3:-}
	mkdir -p "$(dirname "$LEDGER_FILE")"
	if [[ ! -s $LEDGER_FILE || ! $(head -1 "$LEDGER_FILE") =~ ledgerv1 ]]; then
		echo "# ledgerv1 fields=dest,src,component timestamp=$(date -u +%FT%TZ)" >"$LEDGER_FILE.tmp"
		[[ -s $LEDGER_FILE ]] && grep -v '^# ledgerv' "$LEDGER_FILE" >>"$LEDGER_FILE.tmp" || true
		mv "$LEDGER_FILE.tmp" "$LEDGER_FILE"
	fi
	printf '%s\t%s\t%s\n' "$dest" "$src" "$comp" >>"$LEDGER_FILE"
}

fs_symlink() {
	local src=$1 dest=$2 component=${3:-}
	# If transactional mode active and a transaction begun, stage instead
	if [[ ${DOTFILES_TRANSACTIONAL:-0} == 1 && -n ${DOT_TXN_DIR:-} ]]; then
		transaction_stage_symlink "$src" "$dest" "$component"
		return 0
	fi
	if [[ -L $dest && $(readlink "$dest") == "$src" ]]; then
		log_info "Symlink OK: $dest"
		return 0
	fi
	fs_remove_or_backup "$dest"
	mkdir -p "$(dirname "$dest")"
	ln -s "$src" "$dest"
	fs_symlink_record "$dest" "$src" "$component"
	log_info "Linked $dest -> $src"
}
