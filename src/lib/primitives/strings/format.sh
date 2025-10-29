#!/usr/bin/env bash
# strings/format.sh - escape, padding, truncate, repeat

string_escape() { local s="$1"; printf "'%s'\n" "${s//\'/\'\\\'\'}"; }
string_pad_left() { local s="$1" w="$2" pad="${3:- }" len=${#s}; [[ $len -ge $w ]] && { printf '%s\n' "$s"; return; }; local need=$((w-len)); local p; p=$(printf "%*s" "$need" "" | tr ' ' "$pad"); printf '%s\n' "$p$s"; }
string_pad_right() { local s="$1" w="$2" pad="${3:- }" len=${#s}; [[ $len -ge $w ]] && { printf '%s\n' "$s"; return; }; local need=$((w-len)); local p; p=$(printf "%*s" "$need" "" | tr ' ' "$pad"); printf '%s\n' "$s$p"; }
string_truncate() { local s="$1" max="$2" suf="${3:-...}"; [[ ${#s} -le $max ]] && { printf '%s\n' "$s"; return; }; local cut=$((max-${#suf})); printf '%s\n' "${s:0:$cut}$suf"; }
string_repeat() { local s="$1" c="$2" i; for ((i=0;i<c;i++)); do printf '%s' "$s"; done; printf '\n'; }
