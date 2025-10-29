#!/usr/bin/env bash
# msg/format_header.sh - Header rendering

msg_header() {
    _msg_should_print "$MSG_LEVEL_INFO" || return 0
    local text="$*" width text_len padding right_padding
    width=$(_msg_get_width)
    printf "\n%s" "$C_PURPLE"
    printf "%*s\n" "$width" "" | tr ' ' '─'
    printf "%s\n" "$C_RESET"
    text_len=${#text}
    if [[ $text_len -gt $((width-4)) ]]; then text="${text:0:$((width-7))}..."; text_len=${#text}; fi
    padding=$(((width - text_len)/2))
    right_padding=$((width - text_len - padding))
    printf "%*s" "$padding" ""
    printf "%s%s%s" "$C_BOLD" "$C_PURPLE" "$text"
    printf "%*s\n" "$right_padding" ""
    printf "%s" "$C_PURPLE"
    printf "%*s\n" "$width" "" | tr ' ' '─'
    printf "%s\n" "$C_RESET"
}
