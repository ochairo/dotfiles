#!/usr/bin/env bash
# Serial install loop for install

function install_serial_exec() {
  local ordered=("$@")
  local fail=0
  for comp in "${ordered[@]}"; do
    if ! run_component_serial "$comp"; then
      rc=$?
      [[ $rc -eq 2 ]] && { fail=1; break; }
    fi
  done
  return $fail
}

export -f install_serial_exec
