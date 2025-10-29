#!/usr/bin/env bash
# msg/primitives.sh - Base printing helpers

msg_print() { printf "$@" >&2; }
msg_blank() { printf "\n" >&2; }
msg_with_icon() { local icon="$1" color="$2"; shift 2; printf "%s%s%s %s\n" "$color" "$icon" "$C_RESET" "$*" >&2; }
msg_prompt() { printf "%s❯%s " "$C_BLUE" "$C_RESET" >&2; }
msg_dim() { printf "%s%s%s\n" "$C_DIM" "$*" "$C_RESET" >&2; }
