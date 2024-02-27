#!/bin/bash -eu

# Clear the terminal ----------------------------------------------------------
clear

# Set variables -----------------------------------------------------
export BLUE=$(tput setaf 4)
export GRAY=$(tput setaf 8)
export GREEN=$(tput setaf 2)
export RED=$(tput setaf 1)
export NC=$(tput sgr0)
export REPO_DIR=$(pwd)

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
