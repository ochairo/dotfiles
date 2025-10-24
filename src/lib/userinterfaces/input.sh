#!/usr/bin/env bash
# input.sh - Simple user input functions (text, number, confirm)
# Reusable across any shell script project (macOS and Linux compatible)
# shellcheck disable=SC2034  # Variables are used by files that source this

# Prevent double loading
[[ -n "${UI_INPUT_LOADED:-}" ]] && return 0
readonly UI_INPUT_LOADED=1

# Prompt for yes/no confirmation
# Args: prompt_text, default (y/n, optional, defaults to 'n')
# Returns: 0 for yes, 1 for no
# Example: if ui_confirm "Continue?" "y"; then echo "Continuing..."; fi
ui_confirm() {
    local prompt_text="${1}"
    local default="${2:-n}"
    local response

    if [[ "$default" == "y" || "$default" == "Y" ]]; then
        msg_print "${C_GREEN}❯${C_RESET} %s ${C_DIM}(${C_BOLD}Y${C_RESET}${C_DIM}/n)${C_RESET}: " "$prompt_text"
    else
        msg_print "${C_BLUE}❯${C_RESET} %s ${C_DIM}(y/${C_BOLD}N${C_RESET}${C_DIM})${C_RESET}: " "$prompt_text"
    fi

    read -r response
    response="${response:-$default}"

    [[ "$response" =~ ^[Yy] ]]
}

# Prompt for text input (with optional hidden mode for passwords)
# Args: prompt_text, hidden (true/false, defaults to false)
# Returns: entered text
# Example: name=$(ui_input_text "Enter name")
# Example: password=$(ui_input_text "Enter password" true)
ui_input_text() {
    local prompt_text="${1:-Enter text}"
    local hidden="${2:-false}"
    local input_text

    if [[ "$hidden" == "true" ]]; then
        msg_print "${C_YELLOW}❯${C_RESET} %s: " "$prompt_text"
        read -r -s input_text
        msg_blank
    else
        msg_print "${C_BLUE}❯${C_RESET} %s: " "$prompt_text"
        read -r input_text
    fi

    echo "$input_text"
}

# Prompt for numeric input with validation
# Args: prompt_text, min_value (optional), max_value (optional)
# Returns: validated number
# Example: port=$(ui_input_number "Enter port" 1 65535)
ui_input_number() {
    local prompt_text="${1}"
    local min_value="${2:-}"
    local max_value="${3:-}"
    local number

    while true; do
        msg_print "${C_BLUE}❯${C_RESET} %s" "$prompt_text"

        # Add range info if provided
        if [[ -n "$min_value" && -n "$max_value" ]]; then
            msg_print " ${C_DIM}(%s-%s)${C_RESET}" "$min_value" "$max_value"
        elif [[ -n "$min_value" ]]; then
            msg_print " ${C_DIM}(min: %s)${C_RESET}" "$min_value"
        elif [[ -n "$max_value" ]]; then
            msg_print " ${C_DIM}(max: %s)${C_RESET}" "$max_value"
        fi

        msg_print ": "
        read -r number

        # Validate numeric input
        if ! [[ "$number" =~ ^-?[0-9]+$ ]]; then
            msg_error "Please enter a valid number"
            continue
        fi

        # Validate range
        if [[ -n "$min_value" ]] && [ "$number" -lt "$min_value" ]; then
            msg_error "Number must be at least ${min_value}"
            continue
        fi

        if [[ -n "$max_value" ]] && [ "$number" -gt "$max_value" ]; then
            msg_error "Number must be at most ${max_value}"
            continue
        fi

        echo "$number"
        return 0
    done
}
