#!/bin/bash

handle_question() {
  question=$1
  options=("${@:2}")

  while true; do
    echo "${BLUE}$question${NC}"
    for ((i = 0; i < ${#options[@]}; i++)); do
      echo "  $((i + 1)). ${options[i]}"
    done
    read -ers -p "  " choice
    if [[ "$choice" -ge 1 && "$choice" -le ${#options[@]} ]]; then
      selected_option="${options[choice - 1]}"
      return 0
    else
      echo ""
      echo "$RED  Invalid option. Please enter a number between 1 and ${#options[@]}.$NC"
      echo ""
      echo ""
    fi
  done
}
