#!/usr/bin/env bash
# Selection logic for install

function install_selection() {
  local all_components=() selection_current components_to_install=()
  # Build full component list
  if declare -F registry_list_components >/dev/null 2>&1; then
    mapfile -t all_components < <(registry_list_components)
  elif declare -F components_list >/dev/null 2>&1; then
    mapfile -t all_components < <(components_list)
  else
    if [[ -d "$COMPONENTS_DIR" ]]; then
      mapfile -t all_components < <(find "$COMPONENTS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)
    fi
  fi

  # Determine selection (saved vs all)
  # New override: DOT_IGNORE_SELECTION skips saved selection entirely
  if [[ "${DOT_INSTALL_FORCE_ALL:-0}" == 1 || "${DOT_IGNORE_SELECTION:-0}" == 1 ]]; then
    components_to_install=("${all_components[@]}")
  else
    selection_current=$(selection_load || true)
  if [[ -n ${selection_current// /} ]]; then
  for c in $selection_current; do
        if [[ -d "$COMPONENTS_DIR/$c" ]]; then
          components_to_install+=("$c")
        else
          msg_warn "Saved selection contains unknown component: $c (skipping)"
        fi
      done
    else
      components_to_install=("${all_components[@]}")
    fi
  fi

  # Output newline-delimited to ensure proper array capture via mapfile -t
  printf '%s\n' "${components_to_install[@]}"
}

export -f install_selection
