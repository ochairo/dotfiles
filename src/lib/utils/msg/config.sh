#!/usr/bin/env bash
# msg/config.sh - Runtime configuration helpers

msg_set_level() {
    case "${1^^}" in
        ERROR) MSG_LEVEL=ERROR; MSG_THRESHOLD=$MSG_LEVEL_ERROR ;;
        WARN)  MSG_LEVEL=WARN;  MSG_THRESHOLD=$MSG_LEVEL_WARN ;;
        INFO)  MSG_LEVEL=INFO;  MSG_THRESHOLD=$MSG_LEVEL_INFO ;;
        DEBUG) MSG_LEVEL=DEBUG; MSG_THRESHOLD=$MSG_LEVEL_DEBUG ;;
        *) return 1 ;;
    esac
}
