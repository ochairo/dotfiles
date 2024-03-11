#!/bin/bash -eu

echo ""
echo "${COLOR_BLUE}Cleanup.........................................................................${COLOR_DEFAULT}"

brew update
brew upgrade
brew cleanup

if [ $? -ne 0 ]; then
  handle_error "Error running .${SETUP//$PATH_ROOT/}"
else
  echo "${COLOR_GREEN}........................................................................Complete${COLOR_DEFAULT}"
  echo ""
  echo ""
fi
