#!/usr/bin/env bash
# wizard/selection_state.sh - Persist selection

# Selection file stored in repository state directory
: "${DOTFILES_STATE_DIR:=${DOTFILES_ROOT}/.tmp}"
if [[ ! -d "$DOTFILES_STATE_DIR" ]]; then
	mkdir -p "$DOTFILES_STATE_DIR" || echo "Failed to create state dir: $DOTFILES_STATE_DIR" >&2
fi
SELECTION_FILE="${SELECTION_FILE:-${DOTFILES_STATE_DIR}/selection}"
selection_save() { echo "$1" >"$SELECTION_FILE"; }
selection_load() { [[ -f $SELECTION_FILE ]] && cat "$SELECTION_FILE" || return 1; }
