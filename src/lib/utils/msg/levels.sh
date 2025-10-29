#!/usr/bin/env bash
# msg/levels.sh - Log level constants & threshold logic

readonly MSG_LEVEL_ERROR=1
readonly MSG_LEVEL_WARN=2
readonly MSG_LEVEL_INFO=3
readonly MSG_LEVEL_DEBUG=4

MSG_LEVEL=${MSG_LEVEL:-INFO}
case "$MSG_LEVEL" in
    ERROR) MSG_THRESHOLD=$MSG_LEVEL_ERROR ;;
    WARN)  MSG_THRESHOLD=$MSG_LEVEL_WARN ;;
    INFO)  MSG_THRESHOLD=$MSG_LEVEL_INFO ;;
    DEBUG) MSG_THRESHOLD=$MSG_LEVEL_DEBUG ;;
    *) MSG_THRESHOLD=$MSG_LEVEL_INFO ;;
esac

_msg_should_print() { local level_num="$1"; [[ $level_num -le $MSG_THRESHOLD ]]; }
