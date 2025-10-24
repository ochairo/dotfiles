#!/usr/bin/env bash
# select.sh - Single-choice selection menu
# Reusable across any shell script project (macOS and Linux compatible)
# shellcheck disable=SC2034  # Variables are used by files that source this

# Prevent double loading
[[ -n "${UI_SELECT_LOADED:-}" ]] && return 0
readonly UI_SELECT_LOADED=1

# For zsh compatibility - use 0-based array indexing like bash
[[ -n "${ZSH_VERSION:-}" ]] && setopt KSH_ARRAYS

# Prompt for selection from a list of options
# Args: prompt_text, option1, option2, ..., optionN
# Returns: selected option text (return code 0)
# Example: choice=$(ui_select "Choose color" "red" "green" "blue")
ui_select() {
    local prompt_text="${1}"
    shift
    local -a options=("$@")
    local choice
    local selected_index

    # Validate input
    if [[ ${#options[@]} -eq 0 ]]; then
        msg_error "No options provided"
        return 1
    fi

    # Display options
    msg_print "${C_BOLD}%s${C_RESET}\n" "$prompt_text"
    msg_blank

    local i=1
    for option in "${options[@]}"; do
        msg_print "  ${C_CYAN}%d)${C_RESET} %s\n" "$i" "$option"
        ((i++))
    done

    msg_blank

    # Get user selection
    while true; do
        msg_print "${C_BLUE}❯${C_RESET} Select option (1-%d): " "${#options[@]}"
        read -r choice

        # Validate input
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
            selected_index=$((choice - 1))
            echo "${options[$selected_index]}"
            return 0
        else
            msg_error "Invalid selection. Please choose 1-${#options[@]}"
        fi
    done
}
