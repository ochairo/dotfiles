#!/usr/bin/env bash
# wizard/custom.sh - Custom component multiselect

presets_select_custom() {
    local -a all_components
    all_components=()
    while IFS= read -r comp; do
        [[ -n $comp ]] && all_components+=("$comp")
    done < <(components_list 2>/dev/null || true)
    # If components_list unexpectedly empty, attempt direct filesystem enumeration once.
    if [[ ${#all_components[@]} -eq 0 && -d "$COMPONENTS_DIR" ]]; then
        while IFS= read -r comp; do
            [[ -n $comp ]] && all_components+=("$comp")
        done < <(find "$COMPONENTS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)
    fi
    [[ ${#all_components[@]} -gt 0 ]] || { msg_error "No components found in $COMPONENTS_DIR"; return 1; }
    local -a options=() comp desc
    for comp in "${all_components[@]}"; do
        desc=$(components_description "$comp" 2>/dev/null || echo "")
        if [[ -n $desc ]]; then
            desc=$(echo "$desc" | tr -d '"'); [[ ${#desc} -gt 30 ]] && desc="${desc:0:27}..."
            options+=("$comp - $desc")
        else
            options+=("$comp")
        fi
    done
    local selected status
    selected=$(ui_multiselect "Select components to install:" "${options[@]}"); status=$?
    # Propagate back sentinel so caller can re-display previous menu
    if [[ "$selected" == "__BACK__" ]]; then
        echo "__BACK__"
        return 0
    fi
    # User canceled (status non-zero) or empty selection
    if [[ $status -ne 0 || -z $selected ]]; then
        msg_warn "No components selected"
        return 1
    fi
    echo "$selected" | sed 's/ - .*//' | tr ' ' ','
}
