#!/usr/bin/env bash
# ansi.sh - Low-level terminal/ANSI primitives (renamed from ui_ansi.sh)
ui_clear_screen() { printf '\033[2J\033[H' >&2; }
ui_move()        { printf '\033[%d;%dH' "$1" "${2:-1}" >&2; }
ui_clear_line()  { printf '\033[2K' >&2; }
ui_hide_cursor() { tput civis >&2 2>/dev/null || printf '\033[?25l' >&2; }
ui_show_cursor() { tput cnorm >&2 2>/dev/null || printf '\033[?25h' >&2; }
ui_cursor_save() { printf '\033[s' >&2; }
ui_cursor_restore(){ printf '\033[u' >&2; }
ui_scroll_region_reset(){ printf '\033[r' >&2; }
ui_scroll_region(){ printf '\033[%d;%dr' "$1" "$2" >&2; }
ui_alt_screen_enter() { printf '\033[?1049h' >&2; }
ui_alt_screen_leave() { printf '\033[?1049l' >&2; }
export -f ui_alt_screen_enter ui_alt_screen_leave
ui_calc_page_size() { local header=${1:-0} footer=${2:-0} total lines; total=$(tput lines 2>/dev/null || echo 24); lines=$((total - header - footer)); ((lines < 3)) && lines=3; echo "$lines"; }
export -f ui_clear_screen ui_move ui_clear_line ui_hide_cursor ui_show_cursor ui_cursor_save ui_cursor_restore ui_scroll_region_reset ui_scroll_region ui_calc_page_size
