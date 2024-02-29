#!/bin/bash -eu

SETUPS=(
  "$REPO_DIR/scripts/setups/essentials/setup.sh"
  "$REPO_DIR/scripts/setups/zsh/setup.sh"
  "$REPO_DIR/scripts/setups/tmux/setup.sh"
  "$REPO_DIR/scripts/setups/fonts/setup.sh"
  "$REPO_DIR/scripts/setups/git/setup.sh"
  "$REPO_DIR/scripts/setups/vim/setup.sh"
  "$REPO_DIR/scripts/setups/nvim/setup.sh"
  "$REPO_DIR/scripts/setups/iterm/setup.sh"
  "$REPO_DIR/scripts/setups/emacs/setup.sh"
  "$REPO_DIR/scripts/setups/vscode/setup.sh"
  "$REPO_DIR/scripts/setups/flutter/setup.sh"
)

for SETUP in "${SETUPS[@]}"; do
  echo ""
  echo "${BLUE}Running.........................................................................${NC}"
  echo " .${SETUP//$REPO_DIR/}"
  echo ""

  source $SETUP

  if [ $? -ne 0 ]; then
    handle_error "Error running .${SETUP//$REPO_DIR/}"
  else
    echo "${GREEN}........................................................................Complete${NC}"
    echo ""
    echo ""
  fi
done
