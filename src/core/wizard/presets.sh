#!/usr/bin/env bash
# Preset and component selection utilities
# Provides functions for interactive component selection

# shellcheck disable=SC1091
source "${CORE_DIR}/io/ui.sh"
source "${CORE_DIR}/component/categories.sh"

# Show preset selection menu
# Output: menu to stderr
presets_show_menu() {
  local total_count
  total_count=$(categories_count_total)

  {
    echo ""
    echo -e "${UI_BOLD}📦 Select Installation Type:${UI_RESET}"
    echo ""
    echo -e "  ${UI_CYAN}1)${UI_RESET} ${UI_BOLD}Everything${UI_RESET}   ${UI_DIM}→${UI_RESET} Install all ${total_count} components"
    echo -e "  ${UI_CYAN}2)${UI_RESET} ${UI_BOLD}Custom${UI_RESET}       ${UI_DIM}→${UI_RESET} Pick individual components"
    echo -e "  ${UI_CYAN}3)${UI_RESET} ${UI_BOLD}Exit${UI_RESET}         ${UI_DIM}→${UI_RESET} Quit installer"
    echo ""
    ui_print_line "─" "$UI_DIM"
    echo ""
  } >&2
}

# Prompt user to select a preset
# Returns: "ALL", "CUSTOM", or "EXIT"
presets_select() {
  presets_show_menu
  local choice
  choice=$(ui_prompt "Select an option (1-3)" "1")

  case "$choice" in
    1)
      echo "ALL"
      ;;
    2)
      echo "CUSTOM"
      ;;
    3)
      echo "EXIT"
      ;;
    *)
      ui_error "Invalid choice. Installing everything."
      echo "ALL"
      ;;
  esac
}

# Interactive custom component selection
# Returns: space-separated list of selected components
presets_select_custom() {
  local selected=()

  clear
  {
    echo ""
    ui_print_line "─" "$UI_MAGENTA"
    echo ""
    ui_print_centered "🎯  Custom Component Selection  🎯" "${UI_BOLD}${UI_MAGENTA}"
    echo ""
    ui_print_line "─" "$UI_MAGENTA"
    echo ""
    echo -e "  ${UI_DIM}You'll be asked about each component individually.${UI_RESET}"
    echo -e "  ${UI_DIM}Press ${UI_BOLD}y${UI_RESET}${UI_DIM} to install, ${UI_BOLD}Enter${UI_RESET}${UI_DIM} to skip.${UI_RESET}"
    echo ""
    echo ""
  } >&2

  # Get all components sorted
  local all_components
  mapfile -t all_components < <(categories_get_all_components)

  # Ask about each component
  local count=0
  for comp in "${all_components[@]}"; do
    ((count++))
    local category
    category=$(categories_get_category "$comp")
    local icon
    icon=$(categories_get_icon "$category")
    local prompt="${icon} ${UI_BOLD}${comp}${UI_RESET} ${UI_DIM}(${category})${UI_RESET}"

    if ui_confirm "$prompt" "n"; then
      selected+=("$comp")
      echo -e "  ${UI_GREEN}✓${UI_RESET} ${UI_DIM}Added${UI_RESET}"
    fi
  done

  # Return space-separated list
  printf "%s " "${selected[@]}"
}

# Show installation summary
# Args: components (space-separated string)
# Returns: 0 if user confirms, 1 if cancelled
presets_confirm_installation() {
  local components="${1}"
  local count
  count=$(echo "$components" | wc -w | tr -d ' ')

  echo ""
  ui_print_line "─" "$UI_GREEN"
  echo ""
  ui_print_centered "📋  Installation Summary  📋" "${UI_BOLD}${UI_GREEN}"
  echo ""
  ui_print_line "─" "$UI_GREEN"
  echo ""
  echo -e "  ${UI_BOLD}${count}${UI_RESET} components selected for installation:"
  echo ""
  echo "$components" | tr ' ' '\n' | sed 's/^/    • /'
  echo ""
  ui_print_line "─" "$UI_DIM"
  echo ""

  if ! ui_confirm "Ready to install?" "y"; then
    echo ""
    echo -e "  ${UI_YELLOW}✗${UI_RESET} Installation cancelled"
    return 1
  fi

  return 0
}

# Show welcome screen
presets_show_welcome() {
  clear
  echo ""
  echo ""
  ui_print_line "─" "$UI_CYAN"
  echo ""
  ui_print_centered "✨  Welcome to Dotfiles CaC  ✨" "${UI_BOLD}${UI_CYAN}"
  echo ""
  ui_print_line "─" "$UI_CYAN"
  echo ""
  echo -e "  ${UI_DIM}This wizard will help you set up your development environment.${UI_RESET}"
  echo -e "  ${UI_DIM}Choose from preset profiles or customize your selection.${UI_RESET}"
  echo ""
}

# Show completion screen
presets_show_completion() {
  echo ""
  echo ""
  ui_print_line "─" "$UI_GREEN"
  echo ""
  ui_print_centered "🎉  Installation Complete!  🎉" "${UI_BOLD}${UI_GREEN}"
  echo ""
  ui_print_line "─" "$UI_GREEN"
  echo ""
  echo -e "  ${UI_BOLD}Next steps:${UI_RESET}"
  echo ""
  echo -e "    ${UI_CYAN}1.${UI_RESET} Restart your shell: ${UI_DIM}exec \$SHELL${UI_RESET}"
  echo -e "    ${UI_CYAN}2.${UI_RESET} Check health: ${UI_DIM}dot health${UI_RESET}"
  echo -e "    ${UI_CYAN}3.${UI_RESET} See all commands: ${UI_DIM}dot --help${UI_RESET}"
  echo ""
}

# Validate selection (check if any components were selected)
# Args: selection string
# Returns: 0 if valid, 1 if empty
presets_validate_selection() {
  local selection="${1}"

  if [[ -z "$selection" ]] || [[ "$selection" =~ ^[[:space:]]*$ ]]; then
    return 1
  fi
  return 0
}
