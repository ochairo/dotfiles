#!/bin/bash -eu

valid_choice=false
while [ "$valid_choice" == false ]; do
  read -p "${BLUE}Do you want to setup Emacs? (y/n): ${NC}" choice
  case "$choice" in
  y | Y)
    echo "Yes"
    echo ""
    valid_choice=true

    if ! brew list --formula | grep -q "emacs"; then
      brew install emacs
      brew install emacs-dracula

      git clone --depth 1 https://github.com/doomemacs/doomemacs $HOME/.config/emacs
      $HOME/.config/emacs/bin/doom install
    fi
    ;;
  n | N)
    valid_choice=true
    ;;
  *)
    echo "${RED}Invalid choice. Please enter 'y' or 'n'${NC}"
    echo ""
    ;;
  esac
done

exit 0
