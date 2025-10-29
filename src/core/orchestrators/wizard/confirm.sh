#!/usr/bin/env bash
# wizard/confirm.sh - Confirmation before install

presets_confirm_installation() {
    local selection="$1"
    # Full content redraw so previous multiselect list is cleared.
    ui_clear_content_area
    echo ""; msg_info "Components selected for installation:"; echo ""
    IFS=',' read -ra components <<<"$selection"
    local count=0 comp desc name
    for comp in "${components[@]}"; do
        [[ -z $comp ]] && continue
        # Only show component name (no description) as requested. Description kept for potential future tooltip.
        name="$comp"
        echo "  • $name"
        ((count++))
    done
    echo ""; msg_info "Total: $count component(s)"; echo ""
    ui_confirm "Proceed with installation?" "y"
}
