#!/usr/bin/env bash
# Core bootstrap (scaffold) - idempotent loader for core libs.
# Provides: core_require <libname> ...

if [ -n "${DOTFILES_CORE_BOOTSTRAPPED:-}" ]; then
	return 0 2>/dev/null || exit 0
fi
DOTFILES_CORE_BOOTSTRAPPED=1

DOTFILES_ROOT="${DOTFILES_ROOT:-$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)}"
CORE_DIR="$DOTFILES_ROOT/core"
PATH="$DOTFILES_ROOT/bin:$PATH"

_core_map_lib() {
	case "$1" in
	log) echo "$CORE_DIR/log.sh" ;;
	fs) echo "$CORE_DIR/fs.sh" ;;
	env) echo "$CORE_DIR/env.sh" ;;
	os) echo "$CORE_DIR/os.sh" ;;
	selection) echo "$CORE_DIR/selection.sh" ;;
	drift) echo "$CORE_DIR/drift.sh" ;;
	parallel) echo "$CORE_DIR/parallel.sh" ;;
	transactional) echo "$CORE_DIR/transactional.sh" ;;
	registry) echo "$CORE_DIR/registry.sh" ;;
	update) echo "$CORE_DIR/update.sh" ;;
	term) echo "$CORE_DIR/term.sh" ;;
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
