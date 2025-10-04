#!/usr/bin/env bash
# core/fs.sh - filesystem helpers (migration from utils/fs.sh)

set -euo pipefail

# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/constants.sh"
# shellcheck source=/dev/null
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/log.sh"
source "${DOTFILES_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}/core/transactional.sh"

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

fs_symlink_component_files() {
	local component=$1
	local files

	# Get files list from component.yml
	if ! command -v registry_files >/dev/null 2>&1; then
		# Load registry if not already available
		source "$DOTFILES_ROOT/core/registry.sh"
	fi

	files=$(registry_files "$component")

	if [[ -z "$files" ]]; then
		log_debug "No files specified in component.yml for $component"
		return 0
	fi

	# Process each file entry
	while IFS= read -r file_entry; do
		[[ -z "$file_entry" ]] && continue

		# Expand ~ to $HOME
		local dest_path="${file_entry/#~/$HOME}"

		# Determine source path based on destination
		local src_path
		if [[ "$dest_path" == */.config/* ]]; then
			# For ~/.config/* entries, map to src/configs/.config/*
			local config_suffix="${dest_path#*/.config/}"
			src_path="$CONFIGS_DIR/.config/$config_suffix"
		else
			# For other paths, map to src/configs directly
			# Remove leading dot from hidden files for mapping
			local filename
			filename=$(basename "$dest_path")
			# If it starts with a dot, remove it for the source mapping
			if [[ "$filename" == .* ]]; then
				filename="${filename#.}"
			fi
			src_path="$CONFIGS_DIR/$filename"
		fi

		# Check if this is a directory symlink (ends with /)
		if [[ "$dest_path" == */ ]]; then
			# Remove trailing slash for both paths
			dest_path="${dest_path%/}"
			src_path="${src_path%/}"
		fi

		# Check if source exists
		if [[ -e "$src_path" ]]; then
			fs_symlink "$src_path" "$dest_path" "$component"
		else
			log_warn "Source path does not exist: $src_path (for $dest_path)"
		fi
	done <<<"$files"
}
