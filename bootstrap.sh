#!/bin/bash -eu

# Clear the terminal ----------------------------------------------------------
clear

# Set the color variables -----------------------------------------------------
BLUE=$(tput setaf 4)
GRAY=$(tput setaf 8)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
NC=$(tput sgr0)
PDW=$(pwd)

# Set the environment variables -----------------------------------------------
export REPO_DIR=$PDW

# Error handling --------------------------------------------------------------
source $REPO_DIR/scripts/bootstrap/handle_error.sh

# Welcome message -------------------------------------------------------------
source $REPO_DIR/scripts/bootstrap/message_welcome.sh

# Confirmation message --------------------------------------------------------
source $REPO_DIR/scripts/bootstrap/message_confirm.sh

# Homebrew installation -------------------------------------------------------
source $REPO_DIR/scripts/bootstrap/brew_installer.sh

# Homebrew dotfiles -----------------------------------------------------------
source $REPO_DIR/scripts/bootstrap/brew_settings.sh

# Homebrew cleanup ------------------------------------------------------------
source $REPO_DIR/scripts/bootstrap/brew_cleanup.sh

# Complete message ------------------------------------------------------------
source $REPO_DIR/scripts/bootstrap/message_complete.sh

exit 0
