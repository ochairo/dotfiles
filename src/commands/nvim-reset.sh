#!/usr/bin/env bash
# usage: dot nvim-reset [--force] [--no-backup] [--dry-run]
# summary: Reset Neovim config/data/cache (--force, --no-backup, --dry-run options)
# group: editor
set -euo pipefail
# All constants and paths are now provided by the dot script via environment variables
# shellcheck disable=SC1091
source "$CORE_DIR/bootstrap.sh"
core_require log fs

FORCE=0
NO_BACKUP=0
DRY_RUN=0

# Allow LOG_LEVEL alias for convenience
if [[ -n ${LOG_LEVEL:-} && -z ${DOTFILES_LOG_LEVEL:-} ]]; then
	export DOTFILES_LOG_LEVEL="$LOG_LEVEL"
fi
log_debug "nvim-reset start FORCE=$FORCE NO_BACKUP=$NO_BACKUP DRY_RUN=$DRY_RUN"

while [[ $# -gt 0 ]]; do
	case $1 in
	--force)
		FORCE=1
		shift
		;;
	--no-backup)
		NO_BACKUP=1
		shift
		;;
	--dry-run)
		DRY_RUN=1
		shift
		;;
	-h | --help)
		grep -E '^# (usage|summary):' "$0" | sed 's/^# //'
		exit 0
		;;
	*)
		log_warn "Unknown flag $1"
		shift
		;;
	esac
done

# Standard Neovim paths (XDG + legacy)
NVIM_CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/nvim"
NVIM_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
NVIM_STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/nvim"
NVIM_CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/nvim"

TARGETS=()
for d in "$NVIM_CONFIG_DIR" "$NVIM_DATA_DIR" "$NVIM_STATE_DIR" "$NVIM_CACHE_DIR"; do
	[[ -d $d ]] && TARGETS+=("$d")
done

if [[ ${#TARGETS[@]} -eq 0 ]]; then
	log_info "No Neovim directories to remove. Nothing to do."
	exit 0
fi

log_info "Will remove the following Neovim paths:"
for t in "${TARGETS[@]}"; do echo "  - $t"; done
log_debug "Proceeding past target listing (FORCE=$FORCE DRY_RUN=$DRY_RUN NO_BACKUP=$NO_BACKUP)"

if [[ $FORCE -ne 1 ]]; then
	read -r -p "Proceed? (y/N) " ans
	[[ ${ans,,} == y || ${ans,,} == yes ]] || {
		log_warn "Aborted by user"
		exit 1
	}
fi

log_debug "Proceed block finished (FORCE=$FORCE)"

backup_dir=""
if [[ $NO_BACKUP -ne 1 ]]; then
	ts=$(date +%Y%m%d-%H%M%S)
	backup_dir="$HOME/.nvim-backups/nvim-reset-$ts"
	if [[ $DRY_RUN -eq 0 ]]; then
		log_debug "Creating backup at $backup_dir"
		mkdir -p "$backup_dir"
		for t in "${TARGETS[@]}"; do
			base=$(basename "$t")
			tar -C "$(dirname "$t")" -cf "$backup_dir/${base}.tar" "$base"
		done
		log_info "Backup archives created at $backup_dir (one tar per directory)"
	else
		log_info "(dry-run) Would create backup at $backup_dir"
	fi
else
	log_warn "Skipping backup (--no-backup provided)"
fi

if [[ $DRY_RUN -eq 1 ]]; then
	log_info "(dry-run) Would remove directories now"
	exit 0
fi

for t in "${TARGETS[@]}"; do
	log_debug "Removing $t"
	if rm -rf "$t"; then
		log_info "Removed $t"
	else
		rc=$?
		log_error "Failed to remove $t (rc=$rc)"
	fi
done

log_info "Neovim reset complete. You can reinstall with:\n  src/bin/dot install --only nvim"
if [[ -n $backup_dir ]]; then
	cfg_base=$(basename "$NVIM_CONFIG_DIR")
	log_info "To restore config: rm -rf \"$NVIM_CONFIG_DIR\" && tar -C \"$(dirname "$NVIM_CONFIG_DIR")\" -xf \"$backup_dir/${cfg_base}.tar\""
fi
