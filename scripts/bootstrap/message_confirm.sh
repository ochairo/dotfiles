#!/bin/bash -eu

if [ $(uname) != "Darwin" ]; then
  handle_error 1 "This is only for macOS"
fi

# Confirm with the user if they want to continue ------------------------------
valid_choice=false
while [ "$valid_choice" == false ]; do
  read -p "${BLUE}Do you want to continue? (y/n): ${NC}" choice
  case "$choice" in
  y | Y)
    echo "Yes"
    echo ""
    valid_choice=true
    ;;
  n | N)
    echo "No"
    echo "${BLUE}"
    echo "________________________________________________________________________________"
    echo "                              PROCESS CANCELED!"
    echo "${NC}"
    exit 1
    ;;
  *)
    echo "${RED}Invalid choice. Please enter 'y' or 'n'${NC}"
    echo ""
    ;;
  esac
done
