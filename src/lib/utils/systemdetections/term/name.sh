#!/usr/bin/env bash
# term/name.sh - terminal name utilities

term_name() { [[ -n ${TERM_PROGRAM:-} ]] && echo "$TERM_PROGRAM" || [[ -n ${TERMINAL_EMULATOR:-} ]] && echo "$TERMINAL_EMULATOR" || [[ -n ${TERM:-} ]] && echo "$TERM" || echo unknown; }
term_is() { [[ "$(term_name)" == *"$1"* ]]; }
