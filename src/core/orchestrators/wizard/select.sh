#!/usr/bin/env bash
# wizard/select.sh - Preset selection

presets_select() {
    local total_count; total_count=$(components_list | wc -l | tr -d ' ')
    # Simplified choices: custom first, then ALL; exit handled via Esc key
    local choice; choice=$(ui_select "Choose installation mode:" \
        "Custom selection" \
        "Install ALL components (${total_count} total)")
    case "$choice" in
        "Custom selection"*) echo "CUSTOM" ;;
        "Install ALL"*) echo "ALL" ;;
        *) echo "EXIT" ;; # Fallback (should only occur on cancellation)
    esac
}
