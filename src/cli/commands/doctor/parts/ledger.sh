#!/usr/bin/env bash
# doctor/parts/ledger.sh - Ledger status summary

doctor_ledger_summary() {
  declare -Ag LEDGER_COUNTS
  LEDGER_COUNTS=([OK]=0 [MISSING]=0 [BROKEN]=0 [NOTSYMLINK]=0)
  [[ -f $LEDGER_FILE ]] || return 0
  local dest src comp st
  while IFS=$'\t' read -r dest src comp; do
    [[ -z $dest || $dest == \#* ]] && continue
    if [[ -L $dest ]]; then
      if [[ $(readlink "$dest") == "$src" ]]; then
        if [[ -e $dest ]]; then st="OK"; else st="BROKEN"; fi
      else
        st="BROKEN"
      fi
    elif [[ -e $dest ]]; then
      st="NOTSYMLINK"
    else
      st="MISSING"
    fi
    LEDGER_COUNTS[$st]=$((LEDGER_COUNTS[$st]+1))
  done <"$LEDGER_FILE"
}
