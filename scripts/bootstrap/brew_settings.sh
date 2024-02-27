#!/bin/bash -eu

SETTINGS=(
  "$REPO_DIR/scripts/settings/essentials/setup.sh"
  "$REPO_DIR/scripts/settings/zsh/setup.sh"
  "$REPO_DIR/scripts/settings/tmux/setup.sh"
  "$REPO_DIR/scripts/settings/fonts/setup.sh"
  "$REPO_DIR/scripts/settings/git/setup.sh"
  "$REPO_DIR/scripts/settings/vim/setup.sh"
  "$REPO_DIR/scripts/settings/nvim/setup.sh"
  "$REPO_DIR/scripts/settings/iterm/setup.sh"
  "$REPO_DIR/scripts/settings/emacs/setup.sh"
  "$REPO_DIR/scripts/settings/vscode/setup.sh"
  "$REPO_DIR/scripts/settings/flutter/setup.sh"
)

for SETTING in "${SETTINGS[@]}"; do
  echo ""
  echo "${BLUE}Running.........................................................................${NC}"
  echo " .${SETTING//$REPO_DIR/}"
  echo ""

  $SETTING

  if [ $? -ne 0 ]; then
    handle_error "Error running .${SETTING//$REPO_DIR/}"
  else
    echo "${GREEN}........................................................................Complete${NC}"
    echo ""
    echo ""
  fi
done
