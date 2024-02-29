#!/bin/bash -eu

# Clear the terminal ----------------------------------------------------------
clear

# VARIABLES -------------------------------------------------------------------
export BLUE=$(tput setaf 4)
export GRAY=$(tput setaf 8)
export GREEN=$(tput setaf 2)
export RED=$(tput setaf 1)
export NC=$(tput sgr0)
export REPO_DIR=$(pwd)

# HANDLER: Error --------------------------------------------------------------
source $REPO_DIR/scripts/bootstrap/handlers/error.sh

# HANDLER: Question -----------------------------------------------------------
source $REPO_DIR/scripts/bootstrap/handlers/question.sh

# MESSAGE: Welcome ------------------------------------------------------------
source $REPO_DIR/scripts/bootstrap/messages/welcome.sh

# Prepare for setup
source $REPO_DIR/scripts/bootstrap/prepare.sh

# Setup -----------------------------------------------------------------------
source $REPO_DIR/scripts/bootstrap/setup.sh

# Cleanup ---------------------------------------------------------------------
source $REPO_DIR/scripts/bootstrap/cleanup.sh

# MESSAGE: Complete -----------------------------------------------------------
source $REPO_DIR/scripts/bootstrap/messages/complete.sh

exit 0
