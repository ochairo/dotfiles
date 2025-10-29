#!/usr/bin/env bash
# msg/progress.sh - Progress display

msg_progress() {
    _msg_should_print "$MSG_LEVEL_INFO" || return 0
    local current="$1" total="$2"; shift 2; local text="$*" percent=$(( current * 100 / total ))
    printf "%s[%d/%d]%s %s %s(%d%%)%s\n" "$C_DIM" "$current" "$total" "$C_RESET" "$text" "$C_DIM" "$percent" "$C_RESET"
}
