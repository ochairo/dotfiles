#!/usr/bin/env bash
# strings/basic.sh - trim, length, substring, emptiness

string_trim() { local str="$1"; str="${str#"${str%%[![:space:]]*}"}"; str="${str%"${str##*[![:space:]]}"}"; printf '%s\n' "$str"; }
string_length() { printf '%d\n' "${#1}"; }
string_substring() { local string="$1" start="$2" length="${3:-}"; [[ -n "$length" ]] && printf '%s\n' "${string:$start:$length}" || printf '%s\n' "${string:$start}"; }
string_is_empty() { local trimmed; trimmed="$(string_trim "$1")"; [[ -z "$trimmed" ]]; }
