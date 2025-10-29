#!/usr/bin/env bash
function install_write_timing() {
  local total_epoch="$1"
  local -n timings_ref=$2
  {
    printf '{"totalSeconds":%s,"components":{' "$total_epoch"
    i=0
    for k in "${!timings_ref[@]}"; do
      [[ $i -gt 0 ]] && printf ','
      printf '"%s":%s' "$k" "${timings_ref[$k]}"
      i=$((i + 1))
    done
    printf '}}\n'
  } >"$DOTFILES_ROOT/state/install-timing.json" 2>/dev/null || true
  msg_dim "Timing written to state/install-timing.json"
}
export -f install_write_timing
