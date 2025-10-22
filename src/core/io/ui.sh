#!/usr/bin/env bash
# UI/Presentation utilities for interactive commands
# Provides colors, formatting, and user interaction functions

# Cache terminal width at module load
UI_TERM_WIDTH=${COLUMNS:-$(tput cols 2>/dev/null || echo "80")}

# Color definitions
UI_CYAN='\033[0;36m'
UI_BLUE='\033[0;34m'
UI_GREEN='\033[0;32m'
UI_YELLOW='\033[1;33m'
UI_MAGENTA='\033[0;35m'
UI_RED='\033[0;31m'
UI_BOLD='\033[1m'
UI_DIM='\033[2m'
UI_RESET='\033[0m'

# Get terminal width
# Returns: terminal width in characters
ui_get_width() {
  echo "$UI_TERM_WIDTH"
}

# Generate a horizontal line with the given character
# Args: character (default: ─), color (default: DIM)
# Output: colored horizontal line
ui_print_line() {
  local char="${1:-─}"
  local color="${2:-$UI_DIM}"
  local width
  width=$(ui_get_width)
  echo -ne "${color}"
  printf "%${width}s\n" | tr ' ' "$char"
  echo -ne "${UI_RESET}"
}

# Center text in the terminal with optional color
# Args: text, color (default: RESET)
# Output: centered text
ui_print_centered() {
  local text="$1"
  local color="${2:-$UI_RESET}"
  local width
  width=$(ui_get_width)
  local text_len=${#text}
  local padding=$(( (width - text_len) / 2 ))
  echo -e "${color}$(printf "%${padding}s" "")${text}${UI_RESET}"
}

# Display a titled box with content
# Args: title, description (optional)
# Output: formatted box with title
ui_show_box() {
  local title="$1"
  local description="${2:-}"

  echo ""
  ui_print_line "─" "$UI_CYAN"
  echo ""
  ui_print_centered "$title" "${UI_BOLD}${UI_CYAN}"
  echo ""
  ui_print_line "─" "$UI_CYAN"

  if [[ -n "$description" ]]; then
    echo ""
    echo -e "  ${UI_DIM}${description}${UI_RESET}"
  fi
  echo ""
}

# Prompt for user input with a default value
# Args: prompt_text, default_value (optional)
# Returns: user input or default
ui_prompt() {
  local prompt="${1}"
  local default="${2:-}"
  local choice

  if [[ -n "$default" ]]; then
    echo -ne "${UI_BLUE}❯${UI_RESET} ${prompt} ${UI_DIM}[default: ${UI_BOLD}${default}${UI_RESET}${UI_DIM}]${UI_RESET}: " >&2
    read -r choice
    choice="${choice:-$default}"
  else
    echo -ne "${UI_BLUE}❯${UI_RESET} ${prompt}: " >&2
    read -r choice
  fi

  echo "$choice"
}

# Prompt for yes/no confirmation
# Args: prompt_text, default (y/n)
# Returns: 0 for yes, 1 for no
ui_confirm() {
  local prompt="${1}"
  local default="${2:-n}"
  local response

  if [[ "$default" == "y" ]]; then
    echo -ne "${UI_GREEN}❯${UI_RESET} ${prompt} ${UI_DIM}(${UI_BOLD}Y${UI_RESET}${UI_DIM}/n)${UI_RESET}: " >&2
  else
    echo -ne "${UI_BLUE}❯${UI_RESET} ${prompt} ${UI_DIM}(y/${UI_BOLD}N${UI_RESET}${UI_DIM})${UI_RESET}: " >&2
  fi

  read -r response
  response="${response:-$default}"

  [[ "$response" =~ ^[Yy] ]]
}

# Show a success message
# Args: message
ui_success() {
  echo -e "  ${UI_GREEN}✓${UI_RESET} ${1}"
}

# Show an error message
# Args: message
ui_error() {
  echo -e "  ${UI_RED}✗${UI_RESET} ${1}" >&2
}

# Show a warning message
# Args: message
ui_warning() {
  echo -e "  ${UI_YELLOW}⚠${UI_RESET} ${1}" >&2
}

# Show an info message
# Args: message
ui_info() {
  echo -e "  ${UI_BLUE}ℹ${UI_RESET} ${1}"
}

# Display a menu with numbered options
# Args: title, option1, option2, ..., optionN
# Output: formatted menu
ui_show_menu() {
  local title="$1"
  shift
  local options=("$@")

  echo ""
  echo -e "${UI_BOLD}${title}${UI_RESET}"
  echo ""

  local i=1
  for option in "${options[@]}"; do
    echo -e "  ${UI_CYAN}${i})${UI_RESET} ${option}"
    ((i++))
  done

  echo ""
  ui_print_line "─" "$UI_DIM"
  echo ""
}

# Display a list with bullet points
# Args: item1, item2, ..., itemN
# Output: bulleted list
ui_show_list() {
  local items=("$@")

  for item in "${items[@]}"; do
    echo -e "    ${UI_DIM}•${UI_RESET} ${item}"
  done
}

# Show a header with icon and text
# Args: icon, text, color (optional)
ui_header() {
  local icon="$1"
  local text="$2"
  local color="${3:-$UI_BOLD}"

  echo -e "${color}${icon}  ${text}${UI_RESET}"
}

# Display a progress indicator
# Args: current, total, label
ui_progress() {
  local current="$1"
  local total="$2"
  local label="${3:-Processing}"

  local percent=$(( current * 100 / total ))
  echo -e "  ${UI_DIM}[${current}/${total}]${UI_RESET} ${label} ${UI_DIM}(${percent}%)${UI_RESET}"
}

# Clear screen and show header
# Args: title
ui_clear_and_header() {
  clear
  echo ""
  echo ""
  ui_print_line "─" "$UI_CYAN"
  echo ""
  ui_print_centered "$1" "${UI_BOLD}${UI_CYAN}"
  echo ""
  ui_print_line "─" "$UI_CYAN"
  echo ""
}
