#!/usr/bin/env bash
# doctor/parts/health.sh - Component health checks

doctor_health_checks() {
  declare -Ag HEALTH_RESULT
  health_pass=0; health_fail=0
  local comp hc
  for comp in "${components[@]}"; do
    hc=$(registry_health_check "$comp" || true)
    if [[ -z ${hc// /} ]]; then HEALTH_RESULT[$comp]="skip"; continue; fi
    if command -v env_portable_path >/dev/null 2>&1; then _DOT_PORTABLE_PATH="$(env_portable_path)"; export PATH="${_DOT_PORTABLE_PATH}:$PATH"; fi
    if bash -c "$hc" >/dev/null 2>&1; then HEALTH_RESULT[$comp]="pass"; ((health_pass++)); else HEALTH_RESULT[$comp]="fail"; ((health_fail++)); fi
  done
  critical_failing=()
  for comp in "${components[@]}"; do
    if registry_is_critical "$comp" && [[ ${HEALTH_RESULT[$comp]:-skip} == fail ]]; then critical_failing+=("$comp"); fi
  done
}
