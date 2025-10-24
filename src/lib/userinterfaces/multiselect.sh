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
        msg_error "No options provided"
        return 1
    fi

    # Initialize selection status array (0=false, 1=true for each option)
    local -a selected_status=()
    for ((idx=0; idx<${#options[@]}; idx++)); do
        selected_status+=("0")
    done

    # Pagination and filter variables
    local page=0
    local page_size=20
    local filter=""
    local -a filtered_indices=()

    # Initialize filtered indices (all items initially)
    for ((idx=0; idx<${#options[@]}; idx++)); do
        filtered_indices+=("$idx")
    done

    local total_pages=$(( (${#filtered_indices[@]} + page_size - 1) / page_size ))

    while true; do
        # Clear screen for clean UI
        clear >&2

        # Show filter if active
        if [[ -n "$filter" ]]; then
            msg_print "${C_BOLD}%s${C_RESET} ${C_DIM}(Page %d/%d - Filter: \"%s\")${C_RESET}\n" "$title" "$((page+1))" "$total_pages" "$filter"
        else
            msg_print "${C_BOLD}%s${C_RESET} ${C_DIM}(Page %d/%d)${C_RESET}\n" "$title" "$((page+1))" "$total_pages"
        fi
        msg_blank

        # Calculate page boundaries based on filtered results
        local start=$((page * page_size))
        local end=$((start + page_size))
        if [[ $end -gt ${#filtered_indices[@]} ]]; then
            end=${#filtered_indices[@]}
        fi

        # Show options with checkboxes for current page (filtered)
        if [[ ${#filtered_indices[@]} -eq 0 ]]; then
            msg_warn "No components found matching \"${filter}\"" >&2
            msg_info "Type 'clear' to show all components" >&2
        else
            for ((i=start; i<end; i++)); do
                local idx="${filtered_indices[$i]}"
                if [[ "${selected_status[$idx]}" == "1" ]]; then
                    checkbox="${C_GREEN}☑${C_RESET}"
                else
                    checkbox="${C_DIM}☐${C_RESET}"
                fi
                msg_print "  ${C_CYAN}%d)${C_RESET} %s %s\n" "$((idx+1))" "$checkbox" "${options[$idx]}"
            done
        fi

        msg_blank

        # Show current selections with component names
        local current_selections=""
        local selected_count=0
        for ((idx=0; idx<${#options[@]}; idx++)); do
            if [[ "${selected_status[$idx]}" == "1" ]]; then
                selected_count=$((selected_count + 1))
                # Extract component name (before " - " if present)
                local comp_name="${options[$idx]%% - *}"
                if [[ -z "$current_selections" ]]; then
                    current_selections="$comp_name"
                else
                    current_selections="$current_selections, $comp_name"
                fi
            fi
        done

        if [[ $selected_count -gt 0 ]]; then
            msg_with_icon "✓" "$C_GREEN" "Selected (${selected_count}): ${current_selections}"
        else
            msg_dim "Selected: none"
        fi

        msg_blank
        msg_print "${C_DIM}Filter: ${C_RESET}%s  ${C_DIM}|${C_RESET}  %s\n" "/[component]" "clear"
        msg_print "${C_DIM}Select: ${C_RESET}%s  ${C_DIM}|${C_RESET}  %s  ${C_DIM}|${C_RESET}  %s  ${C_DIM}|${C_RESET}  %s\n" "[number] to check/uncheck" "all" "none" "done"
        msg_print "${C_DIM}Navigate: ${C_RESET}%s  ${C_DIM}|${C_RESET}  %s  ${C_DIM}|${C_RESET}  %s\n" "next" "prev" "quit"
        msg_blank

        # Get user input
        msg_prompt
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
            "n"|"next")
                # Next page
                if [[ $((page + 1)) -lt $total_pages ]]; then
                    page=$((page + 1))
                fi
                ;;
            "p"|"prev"|"previous")
                # Previous page
                if [[ $page -gt 0 ]]; then
                    page=$((page - 1))
                fi
                ;;
            /*)
                # Search/filter
                filter="${choice#/}"
                page=0  # Reset to first page

                # Rebuild filtered indices
                filtered_indices=()
                for ((idx=0; idx<${#options[@]}; idx++)); do
                    if [[ "${options[$idx],,}" == *"${filter,,}"* ]]; then
                        filtered_indices+=("$idx")
                    fi
                done

                # Recalculate total pages
                total_pages=$(( (${#filtered_indices[@]} + page_size - 1) / page_size ))
                [[ $total_pages -eq 0 ]] && total_pages=1
                ;;
            "clear")
                # Clear filter
                filter=""
                page=0
                filtered_indices=()
                for ((idx=0; idx<${#options[@]}; idx++)); do
                    filtered_indices+=("$idx")
                done
                total_pages=$(( (${#filtered_indices[@]} + page_size - 1) / page_size ))
                ;;
            "all")
                # Select all options (filtered or all)
                for idx in "${filtered_indices[@]}"; do
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
                    msg_print "  "
                    msg_error "Invalid selection. Use 1-${#options[@]}, 'all', 'none', 'done', or 'q'"
                    sleep 0.8  # Brief pause so user can see the error
                fi
                ;;
        esac
    done
}
