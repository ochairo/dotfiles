#!/usr/bin/env bash
# multiselect.sh - Multi-choice selection menu with checkboxes
# Reusable across any shell script project (macOS and Linux compatible)
# shellcheck disable=SC2034  # Variables are used by files that source this

# Prevent double loading
[[ -n "${UI_MULTISELECT_LOADED:-}" ]] && return 0
readonly UI_MULTISELECT_LOADED=1

# For zsh compatibility - use 0-based array indexing like bash
[[ -n "${ZSH_VERSION:-}" ]] && setopt KSH_ARRAYS

# Multi-select menu with checkboxes (space-separated selection)
# Args: title, option1, option2, ..., optionN
# Returns: space-separated list of selected options (return code 0), or empty string on cancel (return code 1)
# Example: selections=$(ui_multi_select "Choose components" "git" "nvim" "zsh")
ui_multi_select() {
    local title="$1"
    shift
    local -a options=("$@")
    local choice
    local idx
    local checkbox

    # Validate input
    if [[ ${#options[@]} -eq 0 ]]; then
        echo -e "${C_RED}✗${C_RESET} No options provided" >&2
        return 1
    fi

    # Initialize selection status array (0=false, 1=true for each option)
    local -a selected_status=()
    for ((idx=0; idx<${#options[@]}; idx++)); do
        selected_status+=("0")
    done

    while true; do
        # Clear screen for clean UI
        clear >&2

        echo -e "${C_BOLD}${title}${C_RESET}" >&2
        echo -e "${C_DIM}Use numbers to toggle, 'done' to finish, 'all' to select all, 'none' to clear, 'q' to cancel${C_RESET}" >&2
        echo "" >&2

        # Show options with checkboxes
        for ((idx=0; idx<${#options[@]}; idx++)); do
            if [[ "${selected_status[$idx]}" == "1" ]]; then
                checkbox="${C_GREEN}☑${C_RESET}"
            else
                checkbox="${C_DIM}☐${C_RESET}"
            fi
            echo -e "  ${C_CYAN}$((idx+1)))${C_RESET} ${checkbox} ${options[$idx]}" >&2
        done

        echo "" >&2

        # Show current selections
        local current_selections=""
        for ((idx=0; idx<${#options[@]}; idx++)); do
            if [[ "${selected_status[$idx]}" == "1" ]]; then
                current_selections="${current_selections:+$current_selections }${options[$idx]}"
            fi
        done

        if [[ -n "$current_selections" ]]; then
            echo -e "${C_DIM}Selected: ${current_selections}${C_RESET}" >&2
        else
            echo -e "${C_DIM}Selected: none${C_RESET}" >&2
        fi

        echo "" >&2

        # Get user input
        echo -ne "${C_BLUE}❯${C_RESET} Toggle (1-${#options[@]}), 'all', 'none', 'done', or 'q' to cancel: " >&2
        read -r choice

        case "$choice" in
            "done")
                # Return selected items
                local result=""
                for ((idx=0; idx<${#options[@]}; idx++)); do
                    if [[ "${selected_status[$idx]}" == "1" ]]; then
                        result="${result:+$result }${options[$idx]}"
                    fi
                done
                echo "$result"
                return 0
                ;;
            "q"|"quit"|"cancel")
                return 1
                ;;
            "all")
                # Select all options
                for ((idx=0; idx<${#options[@]}; idx++)); do
                    selected_status[$idx]=1
                done
                ;;
            "none")
                # Deselect all options
                for ((idx=0; idx<${#options[@]}; idx++)); do
                    selected_status[$idx]=0
                done
                ;;
            *)
                # Toggle specific option
                if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#options[@]}" ]; then
                    local index=$((choice - 1))
                    if [[ "${selected_status[$index]}" == "1" ]]; then
                        selected_status[$index]=0
                    else
                        selected_status[$index]=1
                    fi
                else
                    echo -e "${C_RED}✗${C_RESET} Invalid selection. Use 1-${#options[@]}, 'all', 'none', 'done', or 'q'" >&2
                    sleep 0.8  # Brief pause so user can see the error
                fi
                ;;
        esac
    done
}
