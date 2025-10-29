#!/usr/bin/env bash
# arrays/functional.sh - Functional style array utilities (filter/map/take/skip/append/remove/is_empty)

array_filter() { local pattern="$1"; shift; local item; for item in "$@"; do [[ "$item" =~ $pattern ]] && printf '%s\n' "$item"; done; }
array_map() { local func="$1"; shift; local item; for item in "$@"; do "$func" "$item"; done; }
array_take() { local count="$1"; shift; local i=0 item; for item in "$@"; do [[ $i -ge $count ]] && break; printf '%s\n' "$item"; ((i++)); done; }
array_skip() { local count="$1"; shift; local i=0 item; for item in "$@"; do [[ $i -ge $count ]] && printf '%s\n' "$item"; ((i++)); done; }
array_append_unique() { local element="$1"; shift; printf '%s\n' "$@"; array_contains "$element" "$@" || printf '%s\n' "$element"; }
array_remove() { local element="$1"; shift; local item; for item in "$@"; do [[ "$item" != "$element" ]] && printf '%s\n' "$item"; done; }
array_is_empty() { [[ $# -eq 0 ]]; }
