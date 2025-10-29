#!/usr/bin/env bash
# term/cursor.sh - cursor and screen control

term_clear() { command -v tput >/dev/null 2>&1 && (tput clear 2>/dev/null || clear) || clear 2>/dev/null || printf '\033[2J\033[H'; }
term_cursor_move() { local row="${1:-1}" col="${2:-1}"; command -v tput >/dev/null 2>&1 && tput cup "$row" "$col" 2>/dev/null || printf '\033[%d;%dH' "$row" "$col"; }
term_cursor_hide() { command -v tput >/dev/null 2>&1 && tput civis 2>/dev/null || printf '\033[?25l'; }
term_cursor_show() { command -v tput >/dev/null 2>&1 && tput cnorm 2>/dev/null || printf '\033[?25h'; }
