#!/usr/bin/env bash
set -euo pipefail
# core/term.sh - terminal capability detection

TERM_TRUECOLOR=0
TERM_EMOJI=1
export TERM_TRUECOLOR TERM_EMOJI

_term_detect() {
	if [[ ${COLORTERM:-} == *truecolor* ]] || grep -qi 'truecolor' <<<"${TERM:-}"; then
		TERM_TRUECOLOR=1
	elif command -v tput >/dev/null 2>&1 && tput colors 2>/dev/null | grep -q '256'; then
		TERM_TRUECOLOR=0
	fi
	case "${OSTYPE:-}" in
	darwin*) TERM_EMOJI=1 ;;
	esac
	[[ ${DOTFILES_NO_EMOJI:-0} == 1 ]] && TERM_EMOJI=0
}

_term_detect
