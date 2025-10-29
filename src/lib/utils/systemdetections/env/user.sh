#!/usr/bin/env bash
# env/user.sh - user / host info

env_home() { [[ -n ${HOME:-} ]] && echo "$HOME" || (command -v getent >/dev/null 2>&1 && getent passwd "$USER" | cut -d: -f6) || echo ~; }
env_user() { [[ -n ${USER:-} ]] && echo "$USER" || [[ -n ${USERNAME:-} ]] && echo "$USERNAME" || whoami 2>/dev/null || echo unknown; }
env_hostname() { [[ -n ${HOSTNAME:-} ]] && echo "$HOSTNAME" || hostname 2>/dev/null || echo unknown; }
env_is_root() { [[ $EUID -eq 0 ]]; }
