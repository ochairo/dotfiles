#!/bin/bash -eu

SETUPS=(
  "$PATH_SETUPS/essentials/setup.sh"
  "$PATH_SETUPS/zsh/setup.sh"
  "$PATH_SETUPS/tmux/setup.sh"
  "$PATH_SETUPS/fonts/setup.sh"
  "$PATH_SETUPS/git/setup.sh"
  "$PATH_SETUPS/vim/setup.sh"
  "$PATH_SETUPS/nvim/setup.sh"
  "$PATH_SETUPS/iterm/setup.sh"
  "$PATH_SETUPS/emacs/setup.sh"
  "$PATH_SETUPS/vscode/setup.sh"
  "$PATH_SETUPS/flutter/setup.sh"
  "$PATH_SETUPS/qemu/setup.sh"
  "$PATH_SETUPS/azure/setup.sh"
  "$PATH_SETUPS/docker/setup.sh"
)

for SETUP in "${SETUPS[@]}"; do
  echo ""
  echo "${COLOR_BLUE}Running.........................................................................${COLOR_DEFAULT}"
  echo " .${SETUP//$PATH_ROOT/}"
  echo ""

  source $SETUP

  if [ $? -ne 0 ]; then
    handle_error "Error running .${SETUP//$PATH_ROOT/}"
  else
    echo "${COLOR_GREEN}........................................................................Complete${COLOR_DEFAULT}"
    echo ""
    echo ""
  fi
done
