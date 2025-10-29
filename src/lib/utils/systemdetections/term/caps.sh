#!/usr/bin/env bash
# term/caps.sh - capability predicates

term_supports_truecolor() { [[ $TERM_TRUECOLOR -eq 1 ]]; }
term_supports_256color() { [[ $TERM_256COLOR -eq 1 ]]; }
term_supports_emoji() { [[ $TERM_EMOJI -eq 1 ]]; }
term_is_interactive() { [[ $TERM_INTERACTIVE -eq 1 ]]; }
term_width() { command -v tput >/dev/null 2>&1 && tput cols 2>/dev/null || echo 80; }
term_height() { command -v tput >/dev/null 2>&1 && tput lines 2>/dev/null || echo 24; }
