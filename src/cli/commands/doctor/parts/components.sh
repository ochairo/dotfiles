#!/usr/bin/env bash
# doctor/parts/components.sh - Component collection & filtering

doctor_collect_components() {
  mapfile -t components < <(registry_list_components)
  if [[ -n $COMP_FILTER ]]; then
    IFS=',' read -r -a subset <<<"$COMP_FILTER"
    local -a filtered=() c
    for c in "${subset[@]}"; do
  if [[ -d "$COMPONENTS_DIR/$c" ]]; then filtered+=("$c"); else if declare -F msg_warn >/dev/null 2>&1; then msg_warn "Unknown component in --components: $c"; else echo "[WARN] Unknown component: $c" >&2; fi; fi
    done
    components=("${filtered[@]}")
  fi
}
