#!/bin/bash -eu

# Clear the terminal ----------------------------------------------------------
clear

# VARIABLES -------------------------------------------------------------------
BLUE=$(tput setaf 4)
GRAY=$(tput setaf 8)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
NC=$(tput sgr0)
REPO_DIR=$(pwd)

# HANDLERS --------------------------------------------------------------------
source $REPO_DIR/scripts/handlers/error.sh
source $REPO_DIR/scripts/handlers/question.sh

# MESSAGE: Welcome ------------------------------------------------------------
source $REPO_DIR/scripts/messages/welcome.sh

# Prepare ---------------------------------------------------------------------
source $REPO_DIR/scripts/prepare.sh

# Setup -----------------------------------------------------------------------
source $REPO_DIR/scripts/setup.sh

# Cleanup ---------------------------------------------------------------------
source $REPO_DIR/scripts/cleanup.sh

# MESSAGE: Complete -----------------------------------------------------------
source $REPO_DIR/scripts/messages/complete.sh

exit 0
