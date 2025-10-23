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
        echo -e "${C_RED}✗${C_RESET} No options provided" >&2
        return 1
    fi

    # Display options
    echo -e "${C_BOLD}${prompt_text}${C_RESET}" >&2
    echo "" >&2

    local i=1
    for option in "${options[@]}"; do
        echo -e "  ${C_CYAN}${i})${C_RESET} ${option}" >&2
        ((i++))
    done

    echo "" >&2

    # Get user selection
    while true; do
        echo -ne "${C_BLUE}❯${C_RESET} Select option (1-${#options[@]}): " >&2
        read -r choice

        # Validate input
        if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
            selected_index=$((choice - 1))
            echo "${options[$selected_index]}"
            return 0
        else
            echo -e "${C_RED}✗${C_RESET} Invalid selection. Please choose 1-${#options[@]}" >&2
        fi
    done
}
