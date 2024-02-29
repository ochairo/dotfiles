#!/bin/bash

handle_question() {
  local res=$1
  question=$2
  options=("${@:3}")

  while true; do
    echo "${BLUE}$question${NC}"
    for ((i = 0; i < ${#options[@]}; i++)); do
      echo "  $((i + 1)). ${options[i]}"
    done
    read -ers -p "  " choice
    if [[ "$choice" -ge 1 && "$choice" -le ${#options[@]} ]]; then
      eval $res="${options[choice - 1]}"
      return 0
    else
      echo ""
      echo "$RED  Invalid option. Please enter a number between 1 and ${#options[@]}.$NC"
      echo ""
      echo ""
    fi
  done
}
