#!/usr/bin/env bash
# init/selection.sh - Component selection logic

init_select_components() {
  local selection=""
  if [[ $NO_WIZARD == 1 ]]; then
    if [[ $REPEAT_MODE == 1 ]]; then
      selection=$(selection_load || true)
  if [[ -z ${selection// /} ]]; then msg_warn "No previous selection found; defaulting to ALL"; selection=""; else msg_info "Using previous selection (repeat mode): $selection"; fi
    else
      selection=$(selection_load || true)
  if [[ -n ${selection// /} ]]; then msg_info "Using existing saved selection: $selection"; else selection=""; msg_info "No saved selection; defaulting to ALL components"; fi
    fi
  else
    presets_show_welcome
    selection=$(presets_select)
  if [[ $selection == EXIT ]]; then msg_info "Exiting..."; exit 0; fi
    if [[ $selection == CUSTOM ]]; then
      while true; do
        selection=$(presets_select_custom)
        if [[ $selection == __BACK__ ]]; then
          # Return to preset selection screen
          selection=$(presets_select)
          if [[ $selection == EXIT ]]; then msg_info "Exiting..."; exit 0; fi
          if [[ $selection == CUSTOM ]]; then
            # Loop again into custom selection
            continue
          fi
        fi
        # Break loop when not back sentinel
        break
      done
      if ! presets_validate_selection "$selection"; then msg_error "No components selected. Exiting."; exit 0; fi
    elif [[ $selection == ALL ]]; then selection=""; fi
    if [[ -z $selection ]]; then
  msg_info "Installing all components..."; local total_count; total_count=$(categories_count_total)
  if ! ui_confirm "This will install all ${total_count} components. Continue?" "y"; then msg_warn "Installation cancelled by user"; exit 0; fi
    else
      if ! presets_confirm_installation "$selection"; then exit 0; fi
    fi
  fi
  INIT_SELECTION="$selection"
}
