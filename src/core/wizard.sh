#!/usr/bin/env bash
# wizard.sh - Interactive installation wizard functions

# Prevent double loading
[[ -n "${DOTFILES_WIZARD_LOADED:-}" ]] && return 0
readonly DOTFILES_WIZARD_LOADED=1

# Welcome screen
presets_show_welcome() {
    clear
    msg_header "Dotfiles Installation Wizard"
    echo ""
    msg_info "This wizard will help you install and configure your dotfiles."
    msg_info "You can choose to install all components or select specific ones."
    echo ""
}

# Main preset selection menu
presets_select() {
    local total_count
    total_count=$(components_list | wc -l | tr -d ' ')

    # Use ui_select for the installation mode
    local choice
    choice=$(ui_select "Choose installation mode:" \
        "Install ALL components (${total_count} total)" \
        "Select specific components (custom)" \
        "Exit without installing")

    case "$choice" in
        "Install ALL"*)
            echo "ALL"
            ;;
        "Select specific"*)
            echo "CUSTOM"
            ;;
        "Exit"*)
            echo "EXIT"
            ;;
    esac
}

# Custom component selection using ui_multi_select
presets_select_custom() {
    # Get all components
    local -a all_components
    mapfile -t all_components < <(components_list)

    if [[ ${#all_components[@]} -eq 0 ]]; then
        msg_error "No components found in $COMPONENTS_DIR"
        return 1
    fi

    # Build options array with descriptions
    local -a options=()
    for comp in "${all_components[@]}"; do
        local desc
        desc=$(components_description "$comp" 2>/dev/null || echo "")
        if [[ -n "$desc" ]]; then
            # Truncate long descriptions
            if [[ ${#desc} -gt 50 ]]; then
                desc="${desc:0:47}..."
            fi
            options+=("$comp - $desc")
        else
            options+=("$comp")
        fi
    done

    # Use ui_multi_select
    local selected
    selected=$(ui_multi_select "Select components to install:" "${options[@]}")

    if [[ -z "$selected" ]]; then
        msg_warn "No components selected"
        return 1
    fi

    # Extract component names (everything before " - ")
    echo "$selected" | sed 's/ - .*//' | tr ' ' ','
}

# Validate that selection is not empty
presets_validate_selection() {
    local selection="$1"
    [[ -n "$selection" && "$selection" != "," ]]
}

# Confirm installation with summary
presets_confirm_installation() {
    local selection="$1"

    echo ""
    msg_info "Components selected for installation:"
    echo ""

    # Convert comma-separated list to array
    IFS=',' read -ra components <<< "$selection"

    local count=0
    for comp in "${components[@]}"; do
        [[ -z "$comp" ]] && continue
        local desc
        desc=$(components_description "$comp" 2>/dev/null || echo "")
        if [[ -n "$desc" ]]; then
            echo "  • $comp - $desc"
        else
            echo "  • $comp"
        fi
        ((count++))
    done

    echo ""
    msg_info "Total: $count component(s)"
    echo ""

    ui_confirm "Proceed with installation?" "y"
}

# Completion screen
presets_show_completion() {
    echo ""
    msg_header "Installation Complete!"
    echo ""
    msg_success "All selected components have been installed."
    echo ""
    msg_info "Next steps:"
    echo "  • Run 'dot health' to verify component status"
    echo "  • Run 'dot status' to see symlink status"
    echo "  • Restart your shell or run 'source ~/.zshrc' (or ~/.bashrc)"
    echo ""
}

# Category functions
categories_count_total() {
    components_list | wc -l | tr -d ' '
}

categories_list() {
    # Extract unique tags from all components
    local -a tags=()
    while IFS= read -r comp; do
        local comp_tags
        comp_tags=$(components_tags "$comp" 2>/dev/null || echo "")
        if [[ -n "$comp_tags" ]]; then
            IFS=',' read -ra comp_tag_array <<< "$comp_tags"
            for tag in "${comp_tag_array[@]}"; do
                tag=$(echo "$tag" | xargs)  # Trim whitespace
                if [[ -n "$tag" ]]; then
                    tags+=("$tag")
                fi
            done
        fi
    done < <(components_list)

    # Return unique tags
    printf "%s\n" "${tags[@]}" | sort -u
}

# Selection persistence functions
SELECTION_FILE="${SELECTION_FILE:-$HOME/.dotfiles.selection}"

selection_save() {
    local selection="$1"
    echo "$selection" > "$SELECTION_FILE"
}

selection_load() {
    if [[ -f "$SELECTION_FILE" ]]; then
        cat "$SELECTION_FILE"
    else
        return 1
    fi
}
