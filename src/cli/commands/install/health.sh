#!/usr/bin/env bash
# Health check logic and summary for install

function install_health_summary() {
  local -n health_status=$1
  local health_passes=$2
  local health_fails=$3
  if [[ -v health_status && ${#health_status[@]} -gt 0 ]]; then
  if declare -F msg_info >/dev/null 2>&1; then msg_info "Health summary: ${health_passes} passed, ${health_fails} failed"; else echo "Health summary: ${health_passes} passed, ${health_fails} failed" >&2; fi
    if [[ $health_fails -gt 0 ]]; then
      failed_list=()
      for c in "${!health_status[@]}"; do
        if [[ ${health_status[$c]} == fail ]]; then failed_list+=("$c"); fi
      done
      IFS=','
  if declare -F msg_warn >/dev/null 2>&1; then msg_warn "Health failures: ${failed_list[*]}"; else echo "[WARN] Health failures: ${failed_list[*]}" >&2; fi
      unset IFS
    fi
  fi
}

export -f install_health_summary
