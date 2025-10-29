#!/usr/bin/env bash
# ledger/ledger.sh - loader for segmented ledger service
[[ -n "${DOTFILES_LEDGER_LOADED:-}" ]] && return 0
readonly DOTFILES_LEDGER_LOADED=1
LEDGER_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]:-$0}")" && pwd)"
# State directory inside repository
: "${DOTFILES_STATE_DIR:=${DOTFILES_ROOT}/.tmp}"
if [[ ! -d "$DOTFILES_STATE_DIR" ]]; then
	mkdir -p "$DOTFILES_STATE_DIR" || echo "Failed to create state dir: $DOTFILES_STATE_DIR" >&2
fi

# Ledger file relocated to repository .tmp directory
: "${DOTFILES_LEDGER:=${DOTFILES_STATE_DIR}/ledger}"
# Ensure ledger file exists immediately (even before first entry)
if [[ ! -f "$DOTFILES_LEDGER" ]]; then
	: > "$DOTFILES_LEDGER" || echo "Failed to initialize ledger: $DOTFILES_LEDGER" >&2
fi

# shellcheck source=./init.sh
source "${LEDGER_DIR}/init.sh"
# shellcheck source=./query.sh
source "${LEDGER_DIR}/query.sh"
# shellcheck source=./modify.sh
source "${LEDGER_DIR}/modify.sh"
# shellcheck source=./export.sh
source "${LEDGER_DIR}/export.sh"
# shellcheck source=./verify.sh
source "${LEDGER_DIR}/verify.sh"

unset LEDGER_DIR
