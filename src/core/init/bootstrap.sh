#!/usr/bin/env bash
# Core bootstrap (scaffold) - idempotent loader for core libs.
# Provides: core_require <libname> ...

if [ -n "${DOTFILES_CORE_BOOTSTRAPPED:-}" ]; then
	return 0 2>/dev/null || exit 0
fi
DOTFILES_CORE_BOOTSTRAPPED=1

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/../.." && pwd)}"
CORE_DIR="$DOTFILES_ROOT/core"
PATH="$DOTFILES_ROOT/bin:$PATH"

_core_map_lib() {
	case "$1" in
	# I/O
	log) echo "$CORE_DIR/io/log.sh" ;;
	ui) echo "$CORE_DIR/io/ui.sh" ;;
	term) echo "$CORE_DIR/io/term.sh" ;;

	# Filesystem
	fs) echo "$CORE_DIR/fs/fs.sh" ;;
	transactional) echo "$CORE_DIR/fs/transactional.sh" ;;

	# Component management
	registry) echo "$CORE_DIR/component/registry.sh" ;;
	categories) echo "$CORE_DIR/component/categories.sh" ;;
	validation) echo "$CORE_DIR/component/validation.sh" ;;
	dependency) echo "$CORE_DIR/component/dependency.sh" ;;
	selection) echo "$CORE_DIR/component/registry.sh" ;;

	# Installation
	parallel) echo "$CORE_DIR/install/parallel.sh" ;;
	update) echo "$CORE_DIR/install/install_helpers.sh" ;;

	# System
	os) echo "$CORE_DIR/system/os.sh" ;;
	error) echo "$CORE_DIR/system/error.sh" ;;

	# Init
	env) echo "$CORE_DIR/init/constants.sh" ;;

	# Wizard
	presets) echo "$CORE_DIR/wizard/presets.sh" ;;

	# Legacy/deprecated (for backward compatibility)
	drift) echo "$CORE_DIR/drift.sh" ;;
	util) echo "$CORE_DIR/util.sh" ;;

	*) return 1 ;;
	esac
}

core_require() {
	local l p
	for l in "$@"; do
		p=$(_core_map_lib "$l") || {
			echo "Unknown core lib '$l'" >&2
			return 1
		}
		# shellcheck source=/dev/null
		[ -r "$p" ] && source "$p"
	done
}
