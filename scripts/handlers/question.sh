#!/bin/bash

handle_question() {
  local res=$1
  local question=$2
  local options=("${@:3}")

  while true; do
    echo "${BLUE}$question${NC} (Enter a number)"
    for ((i = 0; i < ${#options[@]}; i++)); do
      echo "  $((i + 1)). ${options[i]}"
    done
    read -ers -p "  " choice
    if [[ "$choice" =~ ^[1-9]+$ && "$choice" -ge 1 && "$choice" -le ${#options[@]} ]]; then
      eval "$res='${options[choice - 1]}'"
      return 0
    else
      echo ""
      echo "$RED  Please enter a number.$NC"
      echo ""
      echo ""
    fi
  done
}
