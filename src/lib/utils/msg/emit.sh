#!/usr/bin/env bash
# msg/emit.sh - Standard level emitters

msg_error() { _msg_should_print "$MSG_LEVEL_ERROR" || return 0; msg_with_icon "✗ [ERROR]" "$C_RED" "$@"; }
msg_warn()  { _msg_should_print "$MSG_LEVEL_WARN"  || return 0; msg_with_icon "⚠ [WARN]"  "$C_YELLOW" "$@"; }
msg_info()  { _msg_should_print "$MSG_LEVEL_INFO"  || return 0; msg_with_icon "ℹ [INFO]" "$C_BLUE" "$@"; }
msg_success(){ _msg_should_print "$MSG_LEVEL_INFO"  || return 0; msg_with_icon "✓ [SUCCESS]" "$C_GREEN" "$@"; }
msg_debug() { _msg_should_print "$MSG_LEVEL_DEBUG" || return 0; msg_with_icon "⚬ [DEBUG]" "$C_DIM" "$@"; }
