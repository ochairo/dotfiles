#!/usr/bin/env bash
# doctor/parts/output.sh - JSON & text output

doctor_emit_json() {
  printf '{'
  printf '"update":{"state":"%s","branch":"%s","current":"%s","remote":"%s"},' "$UPDATE_STATE" "$BRANCH" "$CURRENT_REF" "$REMOTE_REF"
  printf '"selection":%s,' "$(printf '%s' "$last_selection" | jq -R 'split(" ")|map(select(length>0))')"
  printf '"health":{"pass":%s,"fail":%s,"components":{' "$health_pass" "$health_fail"
  local i=0 c
  for c in "${components[@]}"; do
    [[ $i -gt 0 ]] && printf ','
    printf '"%s":"%s"' "$c" "${HEALTH_RESULT[$c]}"
    ((i++))
  done
  printf '},"criticalFailing":['
  local j
  for j in "${!critical_failing[@]}"; do printf '%s"%s"' "$([[ $j -gt 0 ]] && echo ',')" "${critical_failing[$j]}"; done
  printf ']},'
  printf '"deps":{"valid":%s},' "$VALID_DEPS"
  printf '"ledger":{' ; local k=0 key
  for key in OK MISSING BROKEN NOTSYMLINK; do [[ $k -gt 0 ]] && printf ','; printf '"%s":%s' "$key" "${LEDGER_COUNTS[$key]}"; ((k++)); done
  printf '},"bashVersion":"%s","exit":%s' "$BASH_VERSION" "$EXIT_CODE"
  printf '}'
  echo
}

doctor_emit_text() {
  local info warn err succ dim
  if declare -F msg_info >/dev/null 2>&1; then
    info=msg_info; warn=msg_warn; err=msg_error; succ=msg_success; dim=msg_dim
  else
    info=echo; warn=echo; err=echo; succ=echo; dim=echo
  fi
  $info "Doctor Report"
  $info "Update: $UPDATE_STATE (branch=$BRANCH local=$CURRENT_REF remote=$REMOTE_REF)"
  $info "Selection: ${last_selection:-<none>}"
  $info "Health: pass=$health_pass fail=$health_fail (strict=$STRICT)"
  if [[ $health_fail -gt 0 ]]; then
    local failing=() c; for c in "${components[@]}"; do [[ ${HEALTH_RESULT[$c]} == fail ]] && failing+=("$c"); done
    $warn "Failing components: ${failing[*]}"
  fi
  if [[ ${#critical_failing[@]} -gt 0 ]]; then $err "Critical failing: ${critical_failing[*]}"; fi
  if [[ $VALID_DEPS == 0 ]]; then $err "Dependency graph validation failed"; else $info "Dependency graph valid"; fi
  $info "Ledger: OK=${LEDGER_COUNTS[OK]} MISSING=${LEDGER_COUNTS[MISSING]} BROKEN=${LEDGER_COUNTS[BROKEN]} NOTSYMLINK=${LEDGER_COUNTS[NOTSYMLINK]}"
}
