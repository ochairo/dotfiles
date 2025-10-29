#!/usr/bin/env bash
# Dependency validation and ordering for install

function install_dep_resolve() {
  local components_to_install=("$@")
  local -a ordered=() seen=()
  # Iterate each component individually to avoid one failure aborting all
  for comp in "${components_to_install[@]}"; do
    # Basic validation of direct dependencies; skip if any missing
    local missing=0
    if declare -F components_requires >/dev/null 2>&1; then
      while IFS= read -r dep; do
        [[ -z "$dep" ]] && continue
        if ! components_exists "$dep"; then
          missing=1; break
        fi
      done < <(components_requires "$comp")
    fi
    if [[ $missing -eq 1 ]]; then
      if declare -F msg_warn >/dev/null 2>&1; then msg_warn "Skipping '$comp' (dependency missing)"; else echo "[WARN] Skipping '$comp' (dependency missing)" >&2; fi
      continue
    fi
    # Resolve ordering for this component
    local _sub=()
    if _sub=($(deps_install_order "$comp")); then
      local s
      for s in "${_sub[@]}"; do
        # de-duplicate
        local already=0
        for e in "${ordered[@]}"; do [[ $e == "$s" ]] && already=1 && break; done
        [[ $already == 0 ]] && ordered+=("$s")
      done
    else
      if declare -F msg_warn >/dev/null 2>&1; then msg_warn "Skipping '$comp' (failed resolver)"; else echo "[WARN] Skipping '$comp' (failed resolver)" >&2; fi
    fi
  done
  if [[ ${#ordered[@]} -eq 0 ]]; then
    if declare -F msg_warn >/dev/null 2>&1; then msg_warn "Dependency resolver failed; falling back to raw component list order"; else echo "[WARN] Resolver failed; using raw order" >&2; fi
    ordered=("${components_to_install[@]}")
  fi
  printf '%s\n' "${ordered[@]}"
}

export -f install_dep_resolve
