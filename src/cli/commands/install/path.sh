#!/usr/bin/env bash
# Portable PATH setup for install

function install_portable_path() {
  local _DOT_PORTABLE_PATH=""
  if command -v env_portable_path >/dev/null 2>&1; then
    _DOT_PORTABLE_PATH="$(env_portable_path)"
  fi
  if [[ -n $_DOT_PORTABLE_PATH ]]; then
    export PATH="$_DOT_PORTABLE_PATH:$PATH"
    msg_debug "Global portable PATH applied: $_DOT_PORTABLE_PATH"
  fi
}

export -f install_portable_path
